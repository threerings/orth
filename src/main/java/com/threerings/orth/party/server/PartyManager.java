//
// Orth - a package of MMO services: rooms, parties, partys, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import java.util.Set;

import com.google.common.collect.Sets;
import com.google.inject.Inject;

import com.samskivert.util.ResultListener;
import com.samskivert.util.StringUtil;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.util.Resulting;

import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.ObjectDeathListener;
import com.threerings.presents.dobj.ObjectDestroyedEvent;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.server.PresentsDObjectMgr;

import com.threerings.orth.Log;
import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.server.AetherNodeRequest;
import com.threerings.orth.aether.server.IgnoreManager;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.chat.data.SpeakRouter;
import com.threerings.orth.chat.server.ChatManager;
import com.threerings.orth.chat.server.DObjectSpeakRouter;
import com.threerings.orth.chat.server.SpeakProvider;
import com.threerings.orth.comms.data.CommSender;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.NodeletAuthName;
import com.threerings.orth.nodelet.server.NodeletManager;
import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyCodes;
import com.threerings.orth.party.data.PartyConfig;
import com.threerings.orth.party.data.PartyInvite;
import com.threerings.orth.party.data.PartyMarshaller;
import com.threerings.orth.party.data.PartyNodelet;
import com.threerings.orth.party.data.PartyObject;
import com.threerings.orth.party.data.PartyPeep;
import com.threerings.orth.party.data.PartyPolicy;
import com.threerings.orth.peer.server.OrthPeerManager;

import static com.threerings.orth.Log.log;

/**
 * Manages a particular party, living on a single node.
 */
public class PartyManager extends NodeletManager
    implements PartyProvider, SpeakProvider
{
    @Override public void didInit ()
    {
        _partyObj = ((PartyObject)_sharedObject);
        _partyId = ((PartyNodelet)_nodelet.nodelet).partyId;

        configurePartyObject();

        _speakRouter = new DObjectSpeakRouter(_partyObj) {
            @Override public Set<Integer> getSpeakReceipients () {
                Set<Integer> result = Sets.newHashSet();
                for (PartyPeep peep : _partyObj.peeps) {
                    result.add(peep.getPlayerId());
                }
                return result;
            }
        };
    }

    public void configure (AetherClientObject creator, PartyConfig config)
    {
        _partyObj.setLeaderId(creator.getPlayerId());
    }

    public PartyObject getPartyObject ()
    {
        return _partyObj;
    }

    public int getPartyId ()
    {
        return _partyId;
    }

    public Set<Integer> getPlayerIds ()
    {
        Set<Integer> result = Sets.newHashSet();
        for (PartyPeep peep : _partyObj.peeps) {
            result.add(peep.getPlayerId());
        }
        return result;
    }

    protected PartierObject getPartier (int partierId)
    {
        AuthName authName = NodeletAuthName.makeKey(PartyNodelet.class, partierId);
        return (PartierObject) _clientMgr.getClientObject(authName);
    }

    // from SpeakProvider
    @Override public void speak (ClientObject caller, String msg, InvocationListener listener)
        throws InvocationException
    {
        _chatMan.sendSpeak(_speakRouter, ((PartierObject) caller).playerName, msg,
            OrthChatCodes.PARTY_CHAT_TYPE, listener);
    }

    /**
     * Fill in info on the party object.
     */
    protected void configurePartyObject ()
    {
        _partyObj.disband = true;
        _partyObj.partyService = _invMgr.registerProvider(this, PartyMarshaller.class);

        // add the Orth speak service for this party
        _partyObj.partyChatService = _invMgr.registerProvider(this, SpeakMarshaller.class);
    }

    /**
     * Constructs a new, uninitialized PartyPeep, or a subclass thereof.
     */
    protected PartyPeep createPeep ()
    {
        return new PartyPeep();
    }

    /**
     * Calls createPeep() and configures it using the given arguments.
     */
    protected PartyPeep buildPeep (PartierObject partier, AppearanceInfo info)
    {
        PartyPeep peep = createPeep();
        peep.name = partier.playerName;
        peep.joinOrder = nextJoinOrder();
        return peep;
    }

    /**
     * Shutdown this party.
     */
    @Override
    public void shutdown ()
    {
        super.shutdown();

        if (!_partyObj.isActive()) {
            return; // already shut down
        }

        // clear the party info from all remaining players' player objects
        for (PartyPeep peep : _partyObj.peeps) {
            endPartierSession(peep.name.getId());
        }
        _invMgr.clearDispatcher(_partyObj.partyService);
        _omgr.destroyObject(_partyObj.getOid());
    }

    /**
     * Called from the access controller when subscription is approved for the specified player.
     */
    public void clientConnected (final PartierObject partier)
    {
        final int playerId = partier.getPlayerId();

        // clear their invites to this party, if any
        _invitedIds.remove(playerId);

        partier.setPartyId(_partyId);

        _peerMgr.invokeSingleNodeRequest(
            createSubscribedRequest(playerId, _nodelet), new ResultListener<AppearanceInfo>() {
            @Override public void requestCompleted (AppearanceInfo result) {
                // listen for them to die
                partier.addListener(new ObjectDeathListener() {
                    public void objectDestroyed (ObjectDestroyedEvent event) {
                        removePlayer(playerId);
                    }
                });
                // Crap, we used to do this in addPlayer, but they could never actually enter the
                // party and leave it hosed. The downside of doing it this way is that we could
                // approve more than MAX_PLAYERS to join the party...
                PartyPeep peep = buildPeep(partier, result);
                doAddPeepToParty(peep);
            }
            @Override public void requestFailed (Exception cause) {
                // TODO - notify the client that we done fucked up
                endPartierSession(playerId);
            }
        });
    }

    /**
     * This is the canonical place to add a peep to the party, so that subclasses can react
     * directly to the addition.
     */
    protected void doAddPeepToParty (PartyPeep peep)
    {
        if (!_partyObj.peeps.contains(peep)) {
            _partyObj.addToPeeps(peep);
        }
    }

    protected SubscribedRequest createSubscribedRequest (int playerId, HostedNodelet hosted)
    {
        return new SubscribedRequest(playerId, hosted);
    }

    // from interface PartyProvider
    public void bootPlayer (PartierObject caller, int playerId,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        requireLeader(caller);
        if (removePlayer(playerId)) {
            // TODO(bruno):
            //PlayerNodeActions.sendNotification(playerId,
            //    new GenericNotification("m.party_booted", Notification.PERSONAL));
        }
    }

    // from interface PartyProvider
    public void assignLeader (PartierObject caller, int playerId,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        requireLeader(caller);

        PartyPeep leader = _partyObj.peeps.get(_partyObj.leaderId);
        PartyPeep peep = _partyObj.peeps.get(playerId);
        if (peep == null || peep == leader) {
            // TODO: nicer error? The player may have just left
            throw new InvocationException(InvocationCodes.E_INTERNAL_ERROR);
        }

        _partyObj.startTransaction();
        try {
            peep.joinOrder = leader.joinOrder;
            leader.joinOrder = leader.joinOrder + 1;
            _partyObj.setLeaderId(peep.name.getId());
            _partyObj.updatePeeps(peep);
            _partyObj.updatePeeps(leader);
        } finally {
            _partyObj.commitTransaction();
        }
    }

    // from interface PartyProvider
    public void updateStatus (PartierObject caller, String status,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        requireLeader(caller);
        if (status == null) {
            throw new InvocationException(InvocationCodes.E_INTERNAL_ERROR);
        }
        status = StringUtil.truncate(status, PartyCodes.MAX_NAME_LENGTH);
        setStatus(status, PartyCodes.STATUS_TYPE_USER);
    }

    // from interface PartyProvider
    public void updatePolicy (PartierObject caller, PartyPolicy policy,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        requireLeader(caller);
        _partyObj.setPolicy(policy);
    }

    // from interface PartyProvider
    public void updateDisband (PartierObject caller, boolean disband,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        requireLeader(caller);
        _partyObj.setDisband(disband);
    }

    // from interface PartyProvider
    public void invitePlayer (final PartierObject inviter, PlayerName invitee,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        if (_partyObj.policy == PartyPolicy.CLOSED &&
            _partyObj.leaderId != inviter.getPlayerId()) {
            throw new InvocationException(PartyCodes.E_CANT_INVITE_CLOSED);
        }

        if (_partyObj.peeps.containsKey(invitee.getKey())) {
            throw new InvocationException(PartyCodes.E_ALREADY_IN_PARTY);
        }

        if (_invitedIds.contains(invitee.getId())) {
            throw new InvocationException(PartyCodes.E_ALREADY_INVITED);
        }

        // the invite can't go through if the recipient is not online
        if (null == _peerMgr.locatePlayer(invitee.getId())) {
            throw new InvocationException(AetherCodes.USER_NOT_ONLINE);
        }

        // make sure one of these folks isn't ignoring the other
        _ignoreMgr.validateCommunication(inviter.getPlayerId(), invitee.getId());

        // add them to the invited set
        _invitedIds.add(invitee.getId());

        final PartyInvite invite = createInvite(inviter, invitee);
        _peerMgr.invokeSingleNodeRequest(new AetherNodeRequest(invitee.getId()) {
            @Override protected void execute (AetherClientObject plobj,
                InvocationService.ResultListener listener) {
                CommSender.receiveComm(plobj, invite);
                listener.requestProcessed(null);
            }
        }, new Resulting<Void>(listener) {
            @Override public void requestCompleted (Void result) {
                super.requestCompleted(result);
                CommSender.receiveComm(inviter, invite);
            }
        });
    }

    protected PartyInvite createInvite (PartierObject inviter, PlayerName invitee)
    {
        return new PartyInvite(inviter.playerName, invitee, _nodelet);
    }

    @Override
    public void moveParty (PartierObject client, HostedLocus locus,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        moveParty(locus);
    }

    protected void moveParty (HostedLocus locus)
    {
        _partyObj.setLocus(locus);
    }

    protected PartierObject requireLeader (ClientObject client)
        throws InvocationException
    {
        PartierObject partier = (PartierObject)client;
        if (partier.getPlayerId() != _partyObj.leaderId) {
            log.warning("Operation requires party leadership", "partier", partier.getPlayerId(),
                "leader", _partyObj.leaderId, new Exception());
            throw new InvocationException(InvocationCodes.E_ACCESS_DENIED);
        }
        return partier;
    }

    /**
     * Remove the specified player from the party.
     * @return true if they were removed.
     */
    protected boolean removePlayer (int playerId)
    {
        // make sure we're still alive and they're actually in
        if (_partyObj == null || !_partyObj.peeps.containsKey(playerId)) { return false; }

        // if they're the last one, just kill the party
        if (_partyObj.peeps.size() == 1 || (_partyObj.leaderId == playerId && _partyObj.disband)) {
            shutdown();
            return true;
        }

        endPartierSession(playerId);

        _partyObj.startTransaction();
        try {
            _partyObj.removeFromPeeps(playerId);
            // maybe reassign the leader
            if (_partyObj.leaderId == playerId) {
                _partyObj.setLeaderId(nextLeader());
            }
        } finally {
            _partyObj.commitTransaction();
        }
        return true;
    }

    protected void endPartierSession (int playerId)
    {
        AetherNodeRequest request = new AetherNodeRequest(playerId) {
            @Override protected void execute (
                    AetherClientObject pl, InvocationService.ResultListener rl) {
                pl.setParty(null);
                rl.requestProcessed(null);
            }
        };
        // the player may have logged off, but otherwise should have only 1 aether login
        if (!_peerMgr.findApplicableNodes(request).isEmpty()) {
            _peerMgr.invokeSingleNodeRequest(request,
                new Resulting<Void>("PartyClearer", Log.log, "playerId", playerId));
        }
    }

    protected void setStatus (String status, byte statusType)
    {
        if (_partyObj.status == null || !_partyObj.status.equals(status) ||
                statusType != _partyObj.statusType) {
            _partyObj.startTransaction();
            try {
                _partyObj.setStatusType(statusType);
                _partyObj.setStatus(status);
            } finally {
                _partyObj.commitTransaction();
            }
        }
    }

    /**
     * Return the next join order.
     */
    protected int nextJoinOrder ()
    {
        // return 1 higher than any other joinOrder, or 0.
        int joinOrder = -1;
        for (PartyPeep peep : _partyObj.peeps) {
            if (peep.joinOrder > joinOrder) {
                joinOrder = peep.joinOrder;
            }
        }
        return (joinOrder + 1);
    }

    /**
     * Return the playerId of the next leader.
     */
    protected int nextLeader ()
    {
        // find the lowest joinOrder
        int joinOrder = Integer.MAX_VALUE;
        int newLeader = 0;
        for (PartyPeep peep : _partyObj.peeps) {
            if (peep.joinOrder < joinOrder) {
                joinOrder = peep.joinOrder;
                newLeader = peep.name.getId();
            }
        }
        return newLeader;
    }

    protected static class SubscribedRequest extends AetherNodeRequest
    {
        public SubscribedRequest (int playerId, HostedNodelet hosted)
        {
            super(playerId);
            _hosted = hosted;
        }

        @Override protected void execute (AetherClientObject player,
            InvocationService.ResultListener listener) {
            player.setParty(_hosted);
            listener.requestProcessed(getAppearanceInfo(player));
        }

        /**
         * Returns appropriate party appearance info for the player.
         */
        protected AppearanceInfo getAppearanceInfo (AetherClientObject player)
        {
            return new AppearanceInfo();
        }

        protected HostedNodelet _hosted;
    }

    /**
     * Captures any relevant info about a player's appearance to include in the party data.
     */
    protected static class AppearanceInfo extends SimpleStreamableObject
    {
    }

    protected SpeakRouter _speakRouter;
    protected PartyObject _partyObj;
    protected int _partyId;

    protected Set<Integer> _invitedIds = Sets.newHashSet();

    @Inject protected PresentsDObjectMgr _omgr;
    @Inject protected ChatManager _chatMan;
    @Inject protected ClientManager _clientMgr;
    @Inject protected IgnoreManager _ignoreMgr;
    @Inject protected InvocationManager _invMgr;
    @Inject protected OrthPeerManager _peerMgr;
}
