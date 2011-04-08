package com.threerings.orth.nodelet.server;

import static com.threerings.orth.Log.log;

import java.util.Map;

import com.google.common.base.Functions;
import com.google.common.base.Objects;
import com.google.common.collect.Maps;
import com.google.inject.Inject;
import com.google.inject.Injector;

import com.samskivert.util.Logger;
import com.samskivert.util.ResultListener;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.net.AuthRequest;
import com.threerings.presents.net.AuthResponse;
import com.threerings.presents.net.AuthResponseData;
import com.threerings.presents.net.BootstrapData;
import com.threerings.presents.net.Credentials;
import com.threerings.presents.server.ChainedAuthenticator;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.ClientResolver;
import com.threerings.presents.server.PresentsDObjectMgr;
import com.threerings.presents.server.PresentsSession;
import com.threerings.presents.server.SessionFactory;
import com.threerings.presents.server.net.AuthingConnection;
import com.threerings.presents.server.net.PresentsConnectionManager;
import com.threerings.util.Name;
import com.threerings.util.Resulting;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthAuthCodes;
import com.threerings.orth.data.TokenCredentials;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.data.NodeletAuthName;
import com.threerings.orth.nodelet.data.NodeletBootstrapData;
import com.threerings.orth.server.persist.OrthPlayerRecord;
import com.threerings.orth.server.persist.OrthPlayerRepository;

/**
 * Main entry point for serving various types of nodelets. Abstraction goals:
 * <ul><li>Passthrough authentication using an aether session on an arbitrary peer.</li>
 * <li>Resolution of client and session</li>
 * <li>Instantiation of the hosted DObject</li></ul>
 */
public abstract class NodeletRegistry extends NodeletHoster
{
    /**
     * Creates a new nodelet registry that will handle all connections with a matching
     * {@link TokenCredentials} instance and provide hosting logic for the associated nodelet type.
     * @param dsetName the name of the DSet in {@link OrthNodeObject} that will contain the
     *        {@link HostedNodelet} instances. Also matches the {@link TokenCredentials#subsystemId}.
     * @param hostName the name we use if this server is chosen to host a nodelet
     * @param ports the ports we use if this server is chosed to host a nodelet
     * @param injector access to globals
     * TODO: isolate the subsystem id and the dset name into an orth-level enum
     */
    public NodeletRegistry (String dsetName, String hostName, int[] ports, Injector injector)
    {
        super(dsetName);
        _host = hostName;
        _ports = ports;

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
        DObject obj = null;
        NodeletManager mgr = null;
        try {
            obj = _omgr.registerObject(createSharedObject(nodelet));
            mgr = _injector.getInstance(_managerClass);
            mgr.init(nodelet, obj);

        } catch (Exception e) {
            log.warning("Problem hosting nodelet", e);
            listener.requestFailed(e);

            // kill the object and manager we created
            if (mgr != null) {
                mgr.shutdown();
            }
            if (obj != null) {
                _omgr.destroyObject(obj.getOid());
            }
            return;
        }

        _mgrs.put(nodelet.getId(), mgr);

        HostedNodelet hosted = new HostedNodelet(nodelet, _host, _ports);
        if (!mgr.prepare(new Resulting<Void>(listener, Functions.constant(hosted)))) {
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
     * Creates the DObject corresponding to this nodeley. This is called early in the hosting
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

    // dependencies
    @Inject protected PresentsDObjectMgr _omgr;
    @Inject protected OrthPlayerRepository _playerRepo;
    @Inject protected Injector _injector;
}
