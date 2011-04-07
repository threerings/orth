package com.threerings.orth.nodelet.server;

import static com.threerings.orth.Log.log;

import java.util.Map;

import com.google.common.base.Objects;
import com.google.common.collect.Maps;
import com.google.inject.Inject;
import com.google.inject.Injector;

import com.samskivert.util.Logger;
import com.samskivert.util.ResultListener;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.data.OrthAuthCodes;
import com.threerings.orth.data.TokenCredentials;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.data.NodeletAuthName;
import com.threerings.orth.nodelet.data.NodeletBootstrapData;
import com.threerings.orth.server.persist.OrthPlayerRecord;
import com.threerings.orth.server.persist.OrthPlayerRepository;
import com.threerings.presents.data.ClientObject;
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

/**
 * Main entry point for serving various types of nodelets. Abstraction goals:
 * <ul><li>Passthrough authentication using an aether session on an arbitrary peer.</li>
 * <li>Resolution of client and session</li>
 * <li>Instantiation of the hosted DObject</li></ul>
 */
public abstract class NodeletRegistry extends NodeletHoster
{
    public NodeletRegistry (String dsetName, Injector injector)
    {
        super(dsetName);

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

    protected boolean validateCredentials (AuthRequest authReq)
    {
        Credentials creds = authReq.getCredentials();
        if (!_credentialsClass.isInstance(creds)) {
            return false;
        }
        TokenCredentials tokenCreds = (TokenCredentials)creds;
        return Objects.equal(tokenCreds.subsystemId, _dsetName);
    }

    protected boolean validateAuthName (Name name)
    {
        if (!(name instanceof NodeletAuthName)) {
             return false;
        }

        NodeletAuthName nname = (NodeletAuthName)name;
        return (nname.getDSetName().equals(_dsetName));
    }

    protected void host (ClientObject caller, Nodelet nodelet,
            ResultListener<HostedNodelet> listener)
    {
        DObject obj = null;
        NodeletManager mgr = null;
        try {
            obj = _omgr.registerObject(createSharedObject(nodelet));
            mgr = _injector.getInstance(_managerClass);
            mgr.init(obj);

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
        //_invoker.
    }

    protected void withCredsClass(Class<? extends TokenCredentials> credentialsClass)
    {
        _credentialsClass = credentialsClass;
    }

    protected void withResolverClass(Class<? extends Resolver> resolverClass)
    {
        _resolverClass = resolverClass;
    }

    protected void withSessionClass(Class<? extends Session> sessionClass)
    {
        _sessionClass = sessionClass;
    }

    protected void withManagerClass(Class<? extends NodeletManager> mgrClass)
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

    protected abstract DObject createSharedObject (Nodelet nodelet);

    protected Class<? extends TokenCredentials> _credentialsClass = TokenCredentials.class;
    protected Class<? extends Resolver> _resolverClass = Resolver.class;
    protected Class<? extends Session> _sessionClass = Session.class;
    protected Class<? extends NodeletManager> _managerClass = NodeletManager.class;

    protected Map<Integer, NodeletManager> _mgrs = Maps.newHashMap();

    // dependencies
    @Inject protected PresentsDObjectMgr _omgr;
    @Inject protected OrthPlayerRepository _playerRepo;
    @Inject protected Injector _injector;
}
