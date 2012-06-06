//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.nodelet.server;

import java.util.Map;
import java.util.Set;

import com.google.common.base.Functions;
import com.google.common.base.Objects;
import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Maps;
import com.google.inject.Inject;
import com.google.inject.Injector;

import com.samskivert.util.Logger;
import com.samskivert.util.ResultListener;

import com.threerings.io.Streamable;

import com.threerings.util.Name;
import com.threerings.util.Resulting;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
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

import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthAuthCodes;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.data.TokenCredentials;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.data.NodeletAuthName;
import com.threerings.orth.nodelet.data.NodeletBootstrapData;
import com.threerings.orth.nodelet.data.NodeletCredentials;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.server.persist.PlayerRecord;
import com.threerings.orth.server.persist.PlayerRepository;

import static com.threerings.orth.Log.log;

/**
 * Main entry point for serving various types of nodelets. Abstraction goals:
 * <ul><li>Passthrough authentication using an aether session on an arbitrary peer.</li>
 * <li>Resolution of client and session</li>
 * <li>Instantiation of the hosted DObject</li>
 * <li>Service registration</li>
 * <li>Cross-peer interaction with nodelets (this is delegated to a strategy object)</li></ul>
 */
public abstract class NodeletRegistry
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
     * Methods for nodelet hosting. That is, the process of finding a server to host a nodelet.
     */
    public interface NodeletHoster
    {
        /**
         * Resolves where the given nodelet is hosted.
         */
        void resolveHosting (ClientObject caller, Nodelet nodelet,
                ResultListener<HostedNodelet> listener);

        /**
         * When the nodelet disappears (its manager its shut down), this method is called to
         * clear out any and all associated mappings and artifacts.
         */
        void clearHosting (Nodelet nodelet);
    }

    /**
     * Creates a new nodelet registry that will handle all connections with a matching
     * {@link NodeletCredentials} instance and provide hosting logic for the associated nodelet
     * type.
     * @param nclass the kind of nodelet this registry registers
     * @param hostName the name we use if this server is chosen to host a nodelet
     * @param ports the ports we use if this server is chosen to host a nodelet
     * @param injector access to globals
     */
    public NodeletRegistry (Class<? extends Nodelet> nclass, String hostName, int[] ports,
            Injector injector)
    {
        _nodeletClass = nclass;
        _host = hostName;
        _ports = ports;

        // set up a local hosting strategy by default.
        // Callers can override by calling setPeeredHostingStrategy
        _hoster = new NodeletRegistry.NodeletHoster() {
            @Override public void resolveHosting (ClientObject caller, Nodelet nodelet,
                    ResultListener<HostedNodelet> listener) {
                listener.requestCompleted(new HostedNodelet(nodelet, _host, _ports));
            }
            @Override public void clearHosting (Nodelet nodelet)
            {
                // nothing to clear out
            }
        };

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
                PlayerRecord player = _playerRepo.loadPlayerForSession(creds.sessionToken);
                if (player == null) {
                    throw new AuthException(OrthAuthCodes.SESSION_EXPIRED);
                }
                PlayerName name = player.getName();
                conn.setAuthName(new NodeletAuthName(_nodeletClass, name.toString(), name.getId()));
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

        injector.getInstance(OrthPeerManager.class).addRegistry(_nodeletClass, this);
    }

    public void resolveHosting (ClientObject caller, Nodelet nodelet,
        ResultListener<HostedNodelet> listener)
    {
        _hoster.resolveHosting(caller, nodelet, listener);
    }

    public void registerManager (Nodelet nodelet, NodeletManager inittedMgr)
    {
        _mgrs.put(nodelet, inittedMgr);
    }

    public String getHost ()
    {
        return _host;
    }

    public int[] getPorts ()
    {
        return _ports;
    }

    public Class<? extends NodeletManager> getManagerClass ()
    {
        return _managerClass;
    }

    public String getServiceField ()
    {
        return _serviceField;
    }

    public Class<? extends InvocationMarshaller<?>> getServiceClass ()
    {
        return _serviceClass;
    }

    /**
     * Invokes the given request on the remote nodelet of the given id and notifies the listener of
     * the result when the request has completed. A failure is reported if the nodelet is not
     * currently hosted, or if the request crashes or fails when executed remotely. This method
     * is protected since it will blow up quite badly if the subclass is not using the peered
     * hosting strategy.
     */
    protected <T> void invokeRemoteRequest (final Nodelet nodelet,
            final Request<T> request, final ResultListener<T> lner)
    {
        Preconditions.checkArgument(_hoster instanceof DSetNodeletHoster);
        final String dsetName = ((DSetNodeletHoster)_hoster).getDSetName();
        final Comparable<?> key = nodelet.getKey();
        final Class<? extends Nodelet> nclass = _nodeletClass;
        PeerManager.NodeRequest req = new PeerManager.NodeRequest() {
            @Override public boolean isApplicable (NodeObject nodeobj) {
                return nodeobj.getSet(dsetName).containsKey(key);
            }

            @Override protected void execute (InvocationService.ResultListener rl) {
                NodeletRegistry reg = peerMan.getRegistry(nclass);
                NodeletManager mgr = reg.getManager(nodelet);
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
                            "dset", dsetName, "nodelet", nodelet);
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
                "nodelet", nodelet, "class", nclass);
            lner.requestFailed(new InvocationException(InvocationCodes.INTERNAL_ERROR));
            return;
        }
        _peerMan.invokeNodeRequest(nodes.iterator().next(), req, new Resulting<T>(lner));
    }

    public Iterable<Nodelet> getHostedNodelets ()
    {
        return ImmutableSet.copyOf(_mgrs.keySet());
    }

    public NodeletManager getManager (Nodelet nodelet)
    {
        return _mgrs.get(nodelet);
    }

    /**
     * Calls the {@link NodeletManager#shutdown()} method and performs other cleanup.
     */
    public void shutdownManager (NodeletManager manager)
    {
        Nodelet nodelet = manager.getNodelet().nodelet;
        boolean hasMgr = _mgrs.remove(nodelet) != null;
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
                _invMgr.clearDispatcher((InvocationMarshaller<?>)
                    obj.getClass().getField(_serviceField).get(obj));
            } catch (Exception e) {
            }
        }
        _omgr.destroyObject(obj.getOid());

        // there is a short period of time when our manager is shut down but we're still
        // potentially advertising across the peers; for now we'll just accept this reality
        _hoster.clearHosting(nodelet);
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
        NodeletCredentials nodeletCreds = (NodeletCredentials)creds;
        return nodeletCreds.nodelet != null && Objects.equal(
            nodeletCreds.nodelet.getClass(), _nodeletClass);
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
        return (nname.getDiscriminator().equals(_nodeletClass.getSimpleName()));
    }


    /**
     * Overrides the default "local only" hosting strategy with one that will negotiate the
     * publishing of nodelets using the peer manager's locking system.
     */
    protected void setPeeredHostingStrategy (final String dsetName, Injector injector)
    {
        // cannot use the member injector because we want this to be callable from subclass ctor
        injector.injectMembers(_hoster = new DSetNodeletHoster(dsetName, _nodeletClass) {
            @Override
            protected HostNodeletRequest createHostingRequest (AuthName caller, Nodelet nodelet) {
                return new NodeletRegistryRequest(caller, nodelet, dsetName,
                    NodeletRegistry.this.getClass().getCanonicalName());
            }
        });
    }

    /**
     * The {@link NodeletRegistry} specific implementation of {@link HostNodeletRequest}.
     *
     * Note that we can't send along _host and _ports and such values as part of the request --
     * the whole point is to have those values come from the node that is actually going to
     * do the hosting!
     *
     * Instead, we send along the name of the {@link NodeletRegistry} subclass itself, and use
     * the guice injector to acquire a singleton reference to it on the remote node. From there
     * we can then query all the properties we requireI hope this is kosher.
     */
    protected static class NodeletRegistryRequest extends HostNodeletRequest
    {
        public NodeletRegistryRequest (
            AuthName caller, Nodelet nodelet, String dSetName, String className)
        {
            super(caller, dSetName, nodelet);
            _className = className;
        }

        @Override protected void hostLocally (AuthName caller, Nodelet nodelet,
                ResultListener<HostedNodelet> listener)
        {
            // find the NodeletRegistry subclass
            Class<?> regClass;
            try {
                regClass = Class.forName(_className);
            } catch (ClassNotFoundException e) {
                log.warning("Eek! Could not find NodeletRegistry subclass", "className", _className);
                throw new IllegalArgumentException(e);
            }
            // acquire a reference to it as a singleton
            NodeletRegistry reg = (NodeletRegistry) _injector.getInstance(regClass);

            HostedNodelet hosted = new HostedNodelet(nodelet, reg.getHost(), reg.getPorts());

            DObject registeredObj = null;
            NodeletManager inittedMgr = null;
            try {
                DObject obj = reg.createSharedObject(nodelet);
                NodeletManager mgr = _injector.getInstance(reg.getManagerClass());
                if (reg.getServiceField() != null) {
                    obj.getClass().getField(reg.getServiceField()).set(obj,
                        _invMgr.registerProvider((InvocationProvider)mgr, reg.getServiceClass()));
                }
                registeredObj = _omgr.registerObject(obj);
                mgr.init(reg, hosted, obj);
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

            reg.registerManager(nodelet, inittedMgr);

            if (!inittedMgr.prepare(new Resulting<Void>(listener, Functions.constant(hosted)))) {
                listener.requestCompleted(hosted);
            }
        }

        protected String _className;

        @Inject protected transient Injector _injector;
        @Inject protected transient PresentsDObjectMgr _omgr;
        @Inject protected transient InvocationManager _invMgr;
    }

    /**
     * Override the credentials class used.
     */
    protected void setCredsClass(Class<? extends NodeletCredentials> credentialsClass)
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
            Class<? extends InvocationMarshaller<?>> serviceClass)
    {
        Preconditions.checkNotNull(serviceClass);
        Preconditions.checkNotNull(serviceField);

        _managerClass = mgrClass;
        _serviceField = serviceField;
        _serviceClass = serviceClass;
    }

    protected static class Resolver extends ClientResolver
    {
    }

    protected static class Session extends PresentsSession
    {
        public Nodelet getNodelet ()
        {
            return ((NodeletCredentials)_areq.getCredentials()).nodelet;
        }

        public NodeletManager getNodeletManager ()
        {
            return ((NodeletRegistry)_authdata)._mgrs.get(getNodelet());
        }

        @Override // from PresentsSession
        protected BootstrapData createBootstrapData ()
        {
            return new NodeletBootstrapData();
        }

        @Override // from PresentsSession
        protected void populateBootstrapData (BootstrapData data)
        {
            super.populateBootstrapData(data);

            if (getNodeletManager() == null) {
                throw new RuntimeException(Logger.format(
                    "Manager not found", "nodelet", getNodelet()));
            }
            ((NodeletBootstrapData)data).targetOid = getNodeletManager().getSharedObject().getOid();
        }
    }

    /**
     * Creates the DObject corresponding to this nodelet. This is called early in the hosting
     * process and should just created the correct type of object.
     */
    public abstract DObject createSharedObject (Nodelet nodelet);

    protected Class<? extends Nodelet> _nodeletClass;
    protected NodeletHoster _hoster;
    protected String _host;
    protected int[] _ports;

    protected Map<Nodelet, NodeletManager> _mgrs = Maps.newHashMap();

    protected Class<? extends NodeletCredentials> _credentialsClass = NodeletCredentials.class;
    protected Class<? extends Resolver> _resolverClass = Resolver.class;
    protected Class<? extends Session> _sessionClass = Session.class;
    protected Class<? extends NodeletManager> _managerClass = NodeletManager.class;
    protected String _serviceField;
    protected Class<? extends InvocationMarshaller<?>> _serviceClass;

    // dependencies
    @Inject protected PresentsDObjectMgr _omgr;
    @Inject protected PlayerRepository _playerRepo;
    @Inject protected Injector _injector;
    @Inject protected InvocationManager _invMgr;
    @Inject protected OrthPeerManager _peerMan;
}
