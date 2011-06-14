//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import java.util.Map;

import com.google.common.base.Function;
import com.google.common.collect.Maps;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Invoker;
import com.samskivert.util.StringUtil;
import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.RootDObjectManager;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.SessionFactory;
import com.threerings.presents.server.net.PresentsConnectionManager;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.PlayerSessionLocator;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.server.OrthDeploymentConfig;

import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;

import com.threerings.orth.party.client.PartyRegistryService;
import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyCodes;
import com.threerings.orth.party.data.PartyCredentials;
import com.threerings.orth.party.data.PartyInfo;
import com.threerings.orth.party.data.PartyObject;
import com.threerings.orth.party.data.PartyRegistryMarshaller;
import com.threerings.orth.party.data.PartySummary;
import static com.threerings.orth.Log.log;

/**
 * The PartyRegistry manages all the PartyManagers on a single node. It handles PartyBoard
 * requests coming from a user's world connection. Once a user is in a party, they talk
 * to their PartyManager via their party connection.
 */
@Singleton
public class PartyRegistry
    implements PartyRegistryProvider
{
    @Inject public PartyRegistry (InvocationManager invmgr, PresentsConnectionManager conmgr,
                                  ClientManager clmgr, PartyAuthenticator partyAuthor)
    {
        invmgr.registerProvider(this, PartyRegistryMarshaller.class, OrthCodes.PARTY_GROUP);
        partyAuthor.init(this); // fiddling to work around a circular dependency
        conmgr.addChainedAuthenticator(partyAuthor);
        clmgr.addSessionFactory(SessionFactory.newSessionFactory(
                                    PartyCredentials.class, PartySession.class,
                                    PartyAuthName.class, PartyClientResolver.class));
    }

    /**
     * Returns the manager for the specified party or null.
     */
    public PartyManager getPartyManager (int partyId)
    {
        return _parties.get(partyId);
    }

    /**
     * Called when a user's party id changes.
     */
    public void updateUserParty (int playerId, int partyId, OrthNodeObject nodeObj)
    {
        PlayerObject playerObj = _playerLocator.lookupPlayer(playerId);
        if (playerObj == null && playerObj == null) {
            return; // this node officially doesn't care
        }

        // we know that the PartySummary for this party is on the same nodeObj
        PartySummary summary = (partyId == 0) ? null : nodeObj.hostedParties.get(partyId);
        if (playerObj != null) {
            updateUserParty(playerObj, summary);
        }
        if (playerObj != null) {
            updateUserParty(playerObj, summary);
        }
    }

    /**
     * Called when a PartyInfo changes. Happens in two places:
     * - from PartyManager, when the info is published.
     * - from OrthPeerNode, when it detects an info change.
     */
    public void partyInfoChanged (PartyInfo oldInfo, PartyInfo newInfo)
    {
        if (oldInfo.leaderId == newInfo.leaderId) {
            return;
        }
    }

    // from PartyBoardProvider
    public void locateParty (ClientObject co, final int partyId, PartyRegistryService.JoinListener jl)
        throws InvocationException
    {
        String pnode = _peerMgr.lookupNodeDatum(new Function<NodeObject, String>() {
            public String apply (NodeObject nobj) {
                return ((OrthNodeObject)nobj).hostedParties.containsKey(partyId)
                    ? nobj.nodeName : null;
            }
        });
        if (pnode == null) {
            throw new InvocationException(PartyCodes.E_NO_SUCH_PARTY);
        }
        jl.foundParty(partyId, _peerMgr.getPeerPublicHostName(pnode), _peerMgr.getPeerPort(pnode));
    }

    // from PartyBoardProvider
    public void createParty (ClientObject caller, String name, boolean inviteAllFriends,
        PartyRegistryService.JoinListener jl)
        throws InvocationException
    {
        PlayerObject player = (PlayerObject)caller;

        if (player.partyId != 0) {
            // TODO: possibly a better error? Surely this will be blocked on the client
            throw new InvocationException(InvocationCodes.E_INTERNAL_ERROR);
        }

        // set up the new PartyObject
        PartyObject pobj = new PartyObject();
        pobj.id = getNextPartyId();
        pobj.name = StringUtil.truncate(name, PartyCodes.MAX_NAME_LENGTH);
        pobj.leaderId = player.getPlayerId();
        pobj.disband = true;
        _omgr.registerObject(pobj);

        PartyManager mgr = _injector.getInstance(PartyManager.class);
        mgr.init(pobj, player.getPlayerId());

        jl.foundParty(pobj.id, _depConf.getPartyHost(), _depConf.getPartyPort());

        _parties.put(pobj.id, mgr);

        if (inviteAllFriends) {
            mgr.inviteAllFriends(player);
        }
    }

    /**
     * Called by a PartyManager when it's removed.
     */
    void partyWasRemoved (int partyId)
    {
        _parties.remove(partyId);
    }

    protected void updateUserParty (PlayerObject userObj, PartySummary party)
    {
        userObj.setParty(party);
    }

    /**
     * Figure out the leaderId of the specified party.
     */
    protected int lookupLeaderId (int partyId)
    {
        PartyInfo info = lookupPartyInfo(partyId);
        return (info == null) ? 0 : info.leaderId;
    }

    /**
     * Look up the PartyInfo from the node objects.
     */
    protected PartyInfo lookupPartyInfo (int partyId)
    {
        final Integer partyKey = partyId;
        return _peerMgr.lookupNodeDatum(new Function<NodeObject, PartyInfo>() {
            public PartyInfo apply (NodeObject nobj) {
                return ((OrthNodeObject)nobj).partyInfos.get(partyKey);
            }
        });
    }

    /**
     * Returns the next party id that may be assigned by this server.
     * Only called from the PartyRegistry, does not need synchronization.
     */
    protected int getNextPartyId ()
    {
        if (_partyIdCounter >= Integer.MAX_VALUE / OrthPeerManager.MAX_NODES) {
            log.warning("ZOMG! We plumb run out of id space", "partyId", _partyIdCounter);
            _partyIdCounter = 0;
        }
        return (_peerMgr.getNodeId() + OrthPeerManager.MAX_NODES * ++_partyIdCounter);
    }

    protected Map<Integer, PartyManager> _parties = Maps.newHashMap();

    protected static final int PARTIES_PER_BOARD = 10;

    /** A counter used to assign party ids on this server. */
    protected static int _partyIdCounter;

    /** Just a unique key. */
    protected static final Object PARTY_PURCHASE_KEY = new Object();

    @Inject protected @MainInvoker Invoker _invoker;
    @Inject protected OrthDeploymentConfig _depConf;
    @Inject protected Injector _injector;
    @Inject protected InvocationManager _invmgr;
    @Inject protected PlayerSessionLocator _playerLocator;
    @Inject protected OrthPeerManager _peerMgr;
    //@Inject protected NotificationManager _notifyMan;
    @Inject protected RootDObjectManager _omgr;
}
