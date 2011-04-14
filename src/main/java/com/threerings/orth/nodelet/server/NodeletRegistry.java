package com.threerings.orth.nodelet.server;

import static com.threerings.orth.Log.log;

import java.lang.reflect.Field;
import java.util.Map;
import java.util.Set;

import com.google.common.base.Functions;
import com.google.common.base.Objects;
import com.google.common.base.Preconditions;
import com.google.common.collect.Maps;
import com.google.inject.Inject;
import com.google.inject.Injector;

import com.samskivert.util.Logger;
import com.samskivert.util.ResultListener;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.net.AuthRequest;
import com.threerings.presents.net.AuthResponse;
import com.threerings.presents.net.AuthResponseData;
import com.threerings.presents.net.BootstrapData;
import com.threerings.presents.net.Credentials;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.server.ChainedAuthenticator;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.ClientResolver;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.server.InvocationProvider;
import com.threerings.presents.server.PresentsDObjectMgr;
import com.threerings.presents.server.PresentsSession;
import com.threerings.presents.server.SessionFactory;
import com.threerings.presents.server.net.AuthingConnection;
import com.threerings.presents.server.net.PresentsConnectionManager;
import com.threerings.util.Name;
import com.threerings.util.Resulting;

import com.threerings.io.Streamable;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthAuthCodes;
import com.threerings.orth.data.TokenCredentials;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.data.NodeletAuthName;
import com.threerings.orth.nodelet.data.NodeletBootstrapData;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.server.persist.OrthPlayerRecord;
import com.threerings.orth.server.persist.OrthPlayerRepository;

/**
 * Main entry point for serving various types of nodelets. Abstraction goals:
 * <ul><li>Passthrough authentication using an aether session on an arbitrary peer.</li>
 * <li>Resolution of client and session</li>
 * <li>Instantiation of the hosted DObject</li>
 * <li>Service registration</li>
 * <li>Cross-peer interaction with nodelets</li></ul>
 */
public abstract class NodeletRegistry extends NodeletHoster
{
    /**
     * Abstracts all the peer-jockeying necessary to execute a peer request on a different server
     * related to a specific node. Beware implementations of this class must be serialized and sent
     * between peers. Anonymous inner classes are typically used but may NOT refer to the outer
     * class instance (or its members).
     * @param <T> the type to be returned from the request, must also be streamable
     */
    public interface Request<T> extends Streamable.Closure
    {
        /**
         * Executes the request on the server hosting the nodelet. The manager is the one assigned
         * to the shared object for the nodelet. Notifies the result listener when the request is
         * complete.
         */
        public abstract void execute (NodeletManager manager, ResultListener<T> rl);
    }

    /**
     * Creates a new nodelet registry that will handle all connections with a matching
     * {@link TokenCredentials} instance and provide hosting logic for the associated nodelet type.
     * @param dsetName the name of the DSet in {@link OrthNodeObject} that will contain the
     *        {@link HostedNodelet} instances. Also matches the {@link TokenCredentials#subsystemId}.
     * @param hostName the name we use if this server is chosen to host a nodelet
     * @param ports the ports we use if this server is chosed to host a nodelet
     * @param injector access to globals
     * TODO: isolate the subsystem id and the dset name into an orth-level wrapper
     */
    public NodeletRegistry (String dsetName, String hostName, int[] ports, Injector injector)
    {
        super(dsetName);
        _host = hostName;
        _ports = ports;

//CWG-JD Why use an Injector to get these rather than taking them in the constructor?
//JD-CWG It reduces irrelevant dependencies and unnecessary coupling in the subclass, I often do
//it for abstract classes. I see it as equivalent to the member injection since those are invisible
//and subclasses need not be concerned with them.
        injector.getInstance(PresentsConnectionManager.class)
                .addChainedAuthenticator(new ChainedAuthenticator() {

            @Override public boolean shouldHandleConnection (AuthingConnection conn)
            {
                return validateCredentials(conn.getAuthRequest());
            }

            @Override protected void processAuthentication (AuthingConnection conn,
                    AuthResponse rsp)
                throws Exception
            {
                TokenCredentials creds = (TokenCredentials)conn.getAuthRequest().getCredentials();
                OrthPlayerRecord player = _playerRepo.loadPlayerForSession(creds.sessionToken);
                if (player == null) {
                    throw new AuthException(OrthAuthCodes.SESSION_EXPIRED);
                }
                PlayerName name = player.getPlayerName();
                conn.setAuthName(new NodeletAuthName(_dsetName, name.toString(), name.getId()));
                rsp.getData().code = AuthResponseData.SUCCESS;
                rsp.authdata = NodeletRegistry.this;
            }
        });

        injector.getInstance(ClientManager.class).addSessionFactory(new SessionFactory() {
            @Override public Class<? extends Session> getSessionClass (AuthRequest areq) {
                return validateCredentials(areq) ? _sessionClass : null;
            }
            @Override public Class<? extends Resolver> getClientResolverClass (Name username) {
                return validateAuthName(username) ? _resolverClass : null;
            }
        });

        injector.getInstance(OrthPeerManager.class).addRegistry(_dsetName, this);
    }

    /**
     * Invokes the given request on the nodelet of the given id and notifies the listener of the
     * result when the request has completed. A failure is reported if the nodelet is not currently
     * hosted, or if the request crashes or fails when executed remotely.
     */
    public <T> void invokeRequest (final int nodeletId, final Request<T> request,
            final ResultListener<T> lner)
    {
        final String dsetName = _dsetName;
        PeerManager.NodeRequest req = new PeerManager.NodeRequest() {
            @Override public boolean isApplicable (NodeObject nodeobj) {
                return nodeobj.getSet(dsetName).containsKey(nodeletId);
            }

            @Override protected void execute (InvocationService.ResultListener rl) {
                NodeletRegistry reg = peerMan.getRegistry(dsetName);
                NodeletManager mgr = reg.getManager(nodeletId);
                if (mgr == null) {
                    // this could happen in theory if the nodelet was just about to unhost as the
                    // request was sent
                    rl.requestFailed(InvocationCodes.INTERNAL_ERROR);
                    return;
                }
                injector.injectMembers(request);
                try {
                    request.execute(mgr, new Resulting<T>(rl));
                } catch (Throwable t) {
                    log.warning("Failed to execute nodelet request", "request", request,
                            "dset", dsetName, "nodeletId", nodeletId);
                    rl.requestFailed(InvocationCodes.INTERNAL_ERROR);
                }
            }
            @Inject transient OrthPeerManager peerMan;
            @Inject transient Injector injector;
        };

        Set<String> nodes = _peerMan.findApplicableNodes(req);
        if (nodes.isEmpty()) {
            lner.requestFailed(new Exception("Nodelet not hosted"));
            return;
        }
        if (nodes.size() > 1) {
            log.warning("Multiple hosts found for nodelet, something is very wrong",
                "nodeletId", nodeletId, "dset", _dsetName);
            lner.requestFailed(new InvocationException(InvocationCodes.INTERNAL_ERROR));
            return;
        }
        _peerMan.invokeNodeRequest(nodes.iterator().next(), req, new Resulting<T>(lner));
    }

    public NodeletManager getManager (int nodeletId)
    {
        return _mgrs.get(nodeletId);
    }

    /**
     * Calls the {@link NodeletManager#shutdown()} method and performs other cleanup.
     */
    public void shutdownManager (NodeletManager manager)
    {
        boolean hasMgr = _mgrs.remove(manager.getNodelet().getId()) != null;
        if (!hasMgr) {
            throw new RuntimeException("Shutting down a manager twice: " + manager.getNodelet());
        }
        DObject obj = manager.getSharedObject();
        try {
            manager.shutdown();
        } catch (Exception e) {
            log.warning("Manager failed to shutdown", "nodelet", manager.getNodelet());
        }
        if (_serviceField != null) {
            try {
                _invMgr.clearDispatcher((InvocationMarshaller)_serviceField.get(obj));
            } catch (IllegalAccessException e) {
            }
        }
        _omgr.destroyObject(obj.getOid());
    }

    /**
     * Checks if the incoming connection is configured to access this registry.
     */
    protected boolean validateCredentials (AuthRequest authReq)
    {
        Credentials creds = authReq.getCredentials();
        if (!_credentialsClass.isInstance(creds)) {
            return false;
        }
        TokenCredentials tokenCreds = (TokenCredentials)creds;
        return Objects.equal(tokenCreds.subsystemId, _dsetName);
    }

    /**
     * Checks that the given auth name was created by this registry.
     */
    protected boolean validateAuthName (Name name)
    {
        if (!(name instanceof NodeletAuthName)) {
             return false;
        }

        NodeletAuthName nname = (NodeletAuthName)name;
        return (nname.getDSetName().equals(_dsetName));
    }

    @Override // from NodeletHoster
    protected void host (AuthName caller, Nodelet nodelet, ResultListener<HostedNodelet> listener)
    {
        HostedNodelet hosted = new HostedNodelet(nodelet, _host, _ports);

        DObject registeredObj = null;
        NodeletManager inittedMgr = null;
        try {
            DObject obj = createSharedObject(nodelet);
            NodeletManager mgr = _injector.getInstance(_managerClass);
            if (_serviceField != null) {
                _serviceField.set(obj, _invMgr.registerProvider((InvocationProvider)mgr,
                        _serviceClass));
            }
            registeredObj = _omgr.registerObject(obj);
            mgr.init(this, hosted, obj);
            mgr.didInit();
            inittedMgr = mgr;

        } catch (Exception e) {
            log.warning("Problem hosting nodelet", e);
            listener.requestFailed(e);

            // kill the object and manager we created
            if (inittedMgr != null) {
                inittedMgr.shutdown();
            }
            if (registeredObj != null) {
                _omgr.destroyObject(registeredObj.getOid());
            }
            return;
        }

        _mgrs.put(nodelet.getId(), inittedMgr);

        if (!inittedMgr.prepare(new Resulting<Void>(listener, Functions.constant(hosted)))) {
            listener.requestCompleted(hosted);
        };
    }

    /**
     * Override the credentials class used.
     */
    protected void setCredsClass(Class<? extends TokenCredentials> credentialsClass)
    {
        _credentialsClass = credentialsClass;
    }

    /**
     * Override the client resolver class.
     */
    protected void setResolverClass(Class<? extends Resolver> resolverClass)
    {
        _resolverClass = resolverClass;
    }

    /**
     * Override the session class.
     */
    protected void setSessionClass(Class<? extends Session> sessionClass)
    {
        _sessionClass = sessionClass;
    }

    /**
     * Override the manager class.
     */
    protected void setManagerClass(Class<? extends NodeletManager> mgrClass)
    {
        _managerClass = mgrClass;
    }

    /**
     * Override the manager class and automatically poke the service in the shared objects when
     * they are created.
     * @param serviceField the name of the field in the shared object that will receive the service.
     *        For example, {@code GuildObject.GUILD_SERVICE}.
     * @param serviceClass the class to instantiate and add to the shared object
     */
    protected <T extends NodeletManager & InvocationProvider> void setManagerClass(
            Class<T> mgrClass, String serviceField,
            Class<? extends InvocationMarshaller> serviceClass)
    {
        Field field;
        try {
            field = mgrClass.getField(Preconditions.checkNotNull(serviceField));
        } catch (Exception e) {
            throw new IllegalArgumentException(e);
        }
        Preconditions.checkNotNull(serviceClass);
        Preconditions.checkArgument(field.getType().isAssignableFrom(serviceClass));

        _managerClass = mgrClass;
        _serviceField = field;
        _serviceClass = serviceClass;
    }

    protected static class Resolver extends ClientResolver
    {
    }

    protected static class Session extends PresentsSession
    {
        @Override // from PresentsSession
        protected BootstrapData createBootstrapData ()
        {
            return new NodeletBootstrapData();
        }

        @Override // from PresentsSession
        protected void populateBootstrapData (BootstrapData data)
        {
            super.populateBootstrapData(data);
            int nodeletId = ((TokenCredentials)_areq.getCredentials()).objectId;
            NodeletManager mgr = ((NodeletRegistry)_authdata)._mgrs.get(nodeletId);
            if (mgr == null) {
                throw new RuntimeException(Logger.format("Manager not found", "nodelet", nodeletId));
            }
            ((NodeletBootstrapData)data).targetOid = mgr.getSharedObject().getOid();
        }
    }

    /**
     * Creates the DObject corresponding to this nodelet. This is called early in the hosting
     * process and should just created the correct type of object.
     */
    protected abstract DObject createSharedObject (Nodelet nodelet);

    protected String _host;
    protected int[] _ports;

    protected Map<Integer, NodeletManager> _mgrs = Maps.newHashMap();

    protected Class<? extends TokenCredentials> _credentialsClass = TokenCredentials.class;
    protected Class<? extends Resolver> _resolverClass = Resolver.class;
    protected Class<? extends Session> _sessionClass = Session.class;
    protected Class<? extends NodeletManager> _managerClass = NodeletManager.class;
    protected Field _serviceField;
    protected Class<? extends InvocationMarshaller> _serviceClass;

    // dependencies
    @Inject protected PresentsDObjectMgr _omgr;
    @Inject protected OrthPlayerRepository _playerRepo;
    @Inject protected Injector _injector;
    @Inject protected InvocationManager _invMgr;
}
