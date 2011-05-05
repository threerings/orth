//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import java.util.List;
import java.util.Map;

import com.google.common.base.Function;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.CollectionUtil;
import com.samskivert.util.Invoker;
import com.samskivert.util.QuickSort;
import com.samskivert.util.StringUtil;
import com.samskivert.util.Tuple;

import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
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
import com.threerings.orth.data.OrthName;
import com.threerings.orth.party.data.PartyBoardMarshaller;
import com.threerings.orth.server.OrthDeploymentConfig;

import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;

import com.threerings.orth.party.client.PartyBoardService;
import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyBoardInfo;
import com.threerings.orth.party.data.PartyCodes;
import com.threerings.orth.party.data.PartyCredentials;
import com.threerings.orth.party.data.PartyInfo;
import com.threerings.orth.party.data.PartyObject;
import com.threerings.orth.party.data.PartySummary;
import com.threerings.orth.party.data.PeerPartyMarshaller;

import static com.threerings.orth.Log.log;

/**
 * The PartyRegistry manages all the PartyManagers on a single node. It handles PartyBoard
 * requests coming from a user's world connection. Once a user is in a party, they talk
 * to their PartyManager via their party connection.
 */
@Singleton
public class PartyRegistry
    implements PartyBoardProvider, PeerPartyProvider
{
    @Inject public PartyRegistry (InvocationManager invmgr, PresentsConnectionManager conmgr,
                                  ClientManager clmgr, PartyAuthenticator partyAuthor)
    {
        invmgr.registerProvider(this, PartyBoardMarshaller.class, OrthCodes.PARTY_GROUP);
        partyAuthor.init(this); // fiddling to work around a circular dependency
        conmgr.addChainedAuthenticator(partyAuthor);
        clmgr.addSessionFactory(SessionFactory.newSessionFactory(
                                    PartyCredentials.class, PartySession.class,
                                    PartyAuthName.class, PartyClientResolver.class));
    }

    /**
     * Called to initialize the PartyRegistry after server startup.
     */
    public void init ()
    {
        _peerMgr.getOrthNodeObject().setPeerPartyService(
            _invmgr.registerProvider(this, PeerPartyMarshaller.class));
    }

    /**
     * Return the size of the specified user's party, or 0 if they're not in a party.
     */
    public int lookupPartyPopulation (PlayerObject user)
    {
        PartySummary party = user.getParty();
        return (party == null) ? 0 : lookupPartyPopulation(party.id);
    }

    /**
     * Can be called to return the current size of any party, even one not hosted on this node.
     */
    public int lookupPartyPopulation (int partyId)
    {
        PartyInfo info = lookupPartyInfo(partyId);
        return (info == null) ? 0 : info.population;
    }

    /**
     * Returns the manager for the specified party or null.
     */
    public PartyManager getPartyManager (int partyId)
    {
        return _parties.get(partyId);
    }

    /**
     * Called on the server that hosts the passed-in player, not necessarily on the server
     * hosting the party.
     */
    public void issueInvite (PlayerObject player, OrthName inviter, int partyId, String partyName)
    {
        // TODO(bruno): Wire up notifications
        //_notifyMan.notify(player, new PartyInviteNotification(inviter, partyId, partyName));
    }

    /**
     * Called when a user's party id changes. Happens in two places:
     * - from PartyManager, when the party is hosted on this node.
     * - from OrthPeerNode, for parties hosted on other nodes.
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

    /**
     * Requests that the supplied player pre-join the specified party. If the method returns
     * normally, the player will have been added to the specified party.
     *
     * @throws InvocationException if the party cannot be joined for some reason.
     */
    public void preJoinParty (OrthName name, int partyId)
        throws InvocationException
    {
        PartyManager mgr = _parties.get(partyId);
        if (mgr == null) {
            throw new InvocationException(PartyCodes.E_NO_SUCH_PARTY);
        }
        mgr.addPlayer(name);
    }

    // from PartyBoardProvider
    public void locateParty (ClientObject co, final int partyId, PartyBoardService.JoinListener jl)
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
    public void getPartyBoard (
        ClientObject caller, final byte mode, final InvocationService.ResultListener rl)
        throws InvocationException
    {
        final PlayerObject player = (PlayerObject)caller;

        final List<PartyBoardInfo> list = Lists.newArrayList();
        for (OrthNodeObject nodeObj : _peerMgr.getOrthNodeObjects()) {
            for (PartyInfo info : nodeObj.partyInfos) {
                if ((info.population >= PartyCodes.MAX_PARTY_SIZE) ||
                    (info.recruitment == PartyCodes.RECRUITMENT_CLOSED)) {
                    continue; // skip: too big, or closed
                }
                if ((mode == PartyCodes.BOARD_AWAITING_PLAYERS) &&
                    (info.statusType != PartyCodes.STATUS_TYPE_LOBBY)) {
                    continue; // skip: we want only boards awaiting players.
                }
                PartySummary summary = nodeObj.hostedParties.get(info.id);
                PartyBoardInfo boardInfo = new PartyBoardInfo(summary, info);
                boardInfo.computeScore(player);
                list.add(boardInfo);
            }
        }

        // sort and prune
        // Note: perhaps create a data structure that only saves the top N items and rolls
        // the rest off.
        QuickSort.sort(list);
        CollectionUtil.limit(list, PARTIES_PER_BOARD);
        rl.requestProcessed(list);
    }

    // from PartyBoardProvider
    public void createParty (
        ClientObject caller, final String name, final boolean inviteAllFriends,
        final PartyBoardService.JoinListener jl)
        throws InvocationException
    {
        final PlayerObject player = (PlayerObject)caller;

        if (player.partyId != 0) {
            // TODO: possibly a better error? Surely this will be blocked on the client
            throw new InvocationException(InvocationCodes.E_INTERNAL_ERROR);
        }

        finishCreateParty(player, name, inviteAllFriends, jl);
    }

    // from PartyBoardProvider & PeerPartyProvider
    public void getPartyDetail (ClientObject caller, final int partyId,
                                final InvocationService.ResultListener rl)
        throws InvocationException
    {
        // see if we can handle it locally
        PartyManager mgr = _parties.get(partyId);
        if (mgr != null) {
            rl.requestProcessed(mgr.getPartyDetail());
            return;
        }

        // otherwise ship it off to the node that handles it
        int sent = _peerMgr.invokeOnNodes(new Function<Tuple<Client,NodeObject>,Boolean>() {
            public Boolean apply (Tuple<Client,NodeObject> clinode) {
                OrthNodeObject mnode = (OrthNodeObject)clinode.right;
                if (!mnode.hostedParties.containsKey(partyId)) {
                    return false;
                }
                mnode.peerPartyService.getPartyDetail(partyId, rl);
                return true;
            }
        });
        if (sent == 0) {
            throw new InvocationException(PartyCodes.E_NO_SUCH_PARTY);
        }
    }

    /**
     * Called by a PartyManager when it's removed.
     */
    void partyWasRemoved (int partyId)
    {
        _parties.remove(partyId);
    }

    /**
     * Finish creating a new party.
     */
    protected void finishCreateParty (PlayerObject player, String name,
        boolean inviteAllFriends, PartyBoardService.JoinListener jl)
    {
        PartyObject pobj = null;
        PartyManager mgr = null;
        try {
            // set up the new PartyObject
            pobj = _omgr.registerObject(new PartyObject());
            pobj.id = getNextPartyId();
            pobj.name = StringUtil.truncate(name, PartyCodes.MAX_NAME_LENGTH);

            // TODO: Hackily use the static default group icon until we figure out how best
            // TODO: to eliminate the icon from the UI
            // TODO(bruno): ^^^^
            //pobj.icon = new StaticMediaDesc(MediaMimeTypes.IMAGE_PNG, "photo", "group_logo",
            //    // we know that we're 66x60
            //    MediaDesc.HALF_VERTICALLY_CONSTRAINED);

            pobj.leaderId = player.getPlayerId();
            pobj.disband = true;

            // create the PartyManager and add the player
            mgr = _injector.getInstance(PartyManager.class);
            mgr.init(pobj, player.getPlayerId());
            mgr.addPlayer(player.playerName);

            jl.foundParty(pobj.id, _depConf.getPartyHost(), _depConf.getPartyPort());

        } catch (Exception e) {
            log.warning("Problem creating party", e);
            if (e instanceof InvocationException) {
                jl.requestFailed(e.getMessage());
            } else {
                jl.requestFailed(InvocationCodes.E_INTERNAL_ERROR);
            }

            // kill the party object we created
            if (mgr != null) {
                mgr.shutdown();
            }
            if (pobj != null) {
                _omgr.destroyObject(pobj.getOid());
            }
            return;
        }

        // if we made it here, then register the party
        _parties.put(pobj.id, mgr);

        if (inviteAllFriends) {
            mgr.inviteAllFriends(player);
        }
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
