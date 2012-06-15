//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Randoms;

import com.threerings.util.Resulting;

import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.data.NodeletAuthName;
import com.threerings.orth.nodelet.server.NodeletManager;
import com.threerings.orth.nodelet.server.NodeletRegistry;
import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyConfig;
import com.threerings.orth.party.data.PartyNodelet;
import com.threerings.orth.party.data.PartyObject;
import com.threerings.orth.party.data.PartyRegistryMarshaller;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.server.OrthDeploymentConfig;

import static com.threerings.orth.Log.log;

/**
 * The PartyRegistry creates PartyManagers on a single node. Once a user is in a party, they talk
 * to their PartyManager via their party connection.
 */
@Singleton
public class PartyRegistry extends NodeletRegistry
    implements PartyRegistryProvider
{
    @Inject
    public PartyRegistry (Injector injector, OrthDeploymentConfig config,
        InvocationManager invmgr)
    {
        super(PartyNodelet.class, config.getPartyHost(),
            new int[] { config.getPartyPort() }, injector);

        invmgr.registerProvider(this, PartyRegistryMarshaller.class, OrthCodes.AETHER_GROUP);

        setPeeredHostingStrategy(OrthNodeObject.HOSTED_PARTIES, injector);

        setResolverClass(PartyResolver.class);
        setSessionClass(PartySession.class);
    }

    protected static class PartySession extends Session
    {
        @Override protected void sessionWillResume ()
        {
            super.sessionWillResume();
            didConnect();
        }
        @Override protected void sessionWillStart ()
        {
            super.sessionWillStart();
            didConnect();
        }

        protected void didConnect ()
        {
            _mgr = (PartyManager) getNodeletManager();
            _mgr.clientConnected((PartierObject) _clobj);
            _name = ((PartierObject) _clobj).playerName;
        }

        @Override protected void sessionConnectionClosed ()
        {
            _mgr.clientDisconnected(_name);
            super.sessionConnectionClosed();
        }

        @Override protected void sessionDidEnd ()
        {
            // e.g. if we disconnected and our session then expired
            _mgr.removePlayer(_name.getId());
        }

        @Override protected long getFlushTime ()
        {
            return 10 * 1000L;
        }

        protected PartyManager _mgr;
        protected PlayerName _name;
    }

    protected static class PartyResolver extends Resolver
    {
        @Override public ClientObject createClientObject ()
        {
            return new PartierObject();
        }

        @Override protected void resolveClientData (ClientObject clobj) throws Exception
        {
            super.resolveClientData(clobj);

            PartierObject partObj = (PartierObject)clobj;
            NodeletAuthName authName = (NodeletAuthName)_username;

            partObj.playerName = new PlayerName(authName.toString(), authName.getId());
        }
    }

    public PartyManager getPartyManager (int partyId)
    {
        return (PartyManager) getManager(new PartyNodelet(partyId));
    }

    @Override
    public void joinParty (final AetherClientObject player, int partyId, ResultListener listener)
        throws InvocationException
    {
        _peerMan.invokeSingleNodeRequest(new PartyRequest<HostedNodelet>(partyId) {
            @Override protected HostedNodelet executeForParty (PartyManager mgr) {
                mgr.addPlayer(player, false);
                return mgr.getNodelet();
            }}, new Resulting<HostedNodelet>(listener) {
            @Override public void requestCompleted (HostedNodelet result) {
                player.setParty(result);
                super.requestCompleted(result);
            }
        });
    }

    @Override
    public void createParty (final AetherClientObject player, final PartyConfig config,
        final ResultListener rl)
        throws InvocationException
    {
        if (player.party != null) {
            log.warning("Player tried to create party while already in one", "player",
                player.playerName, "partyId", ((PartyNodelet) player.party.nodelet).partyId);
            throw new InvocationException(InvocationCodes.E_INTERNAL_ERROR);
        }

        PartyNodelet nodelet;
        do {
            // create random partyId's until we find one that's not in obvious use -- this is not
            // perfect; race conditions could mess it up, but I can't be arsed right now
            nodelet = new PartyNodelet(Randoms.threadLocal().getInt(Integer.MAX_VALUE));
        } while (_peerMan.findHostedNodelet(OrthNodeObject.HOSTED_PARTIES, nodelet) != null);

        _hoster.resolveHosting(player, nodelet, new Resulting<HostedNodelet>(rl) {
            @Override public void requestCompleted (HostedNodelet result) {
                configureManager(result, player, config, rl);
            }
        });
    }

    /**
     * After the party is hosted, we have to somewhat annoyingly do another request to
     * configure the newly minted manager with the leader and the {@link PartyConfig}.
     *
     * Truth be told we could probably avoid this with lots of clever subclassing of the
     * internals of NodeletRegistry, but I'm not in the mood.
     */
    void configureManager (final HostedNodelet nodelet, final AetherClientObject player,
        final PartyConfig config, ResultListener listener)
    {
        _peerMan.invokeSingleNodeRequest(
            new PartyRequest<HostedNodelet>(((PartyNodelet) nodelet.nodelet).partyId) {
                @Override protected HostedNodelet executeForParty (PartyManager mgr) {
                    mgr.configure(player, config);
                    return nodelet;
                }
            }, new Resulting<HostedNodelet>(listener) {
            @Override public void requestCompleted (HostedNodelet result) {
                player.setParty(result);
                super.requestCompleted( result);
            }
        });
    }

    @Override public DObject createSharedObject (Nodelet nodelet)
    {
        return new PartyObject();
    }

    @Override
    public Class<? extends NodeletManager> getManagerClass ()
    {
        return PartyManager.class;
    }

    protected static abstract class PartyRequest<T> extends PeerManager.NodeRequest {
        private final int partyId;

        public PartyRequest (int partyId) {
            this.partyId = partyId;
        }

        @Override public boolean isApplicable (NodeObject nodeobj) {
            return ((OrthNodeObject) nodeobj).hostedParties.containsKey(partyId);
        }

        @Override protected void execute (ResultListener listener) {
            PartyManager mgr = _partyReg.getPartyManager(partyId);
            if (mgr == null) {
                log.warning("Expected to find a party manager here", "partyId", partyId);
                throw new IllegalStateException(InvocationCodes.E_INTERNAL_ERROR);
            }
            listener.requestProcessed(executeForParty(mgr));
        }

        protected abstract T executeForParty (PartyManager mgr);

        @Inject protected transient PartyRegistry _partyReg;
    }
}
