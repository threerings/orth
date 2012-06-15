//
// Orth - a package of MMO services: rooms, parties, partys, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import java.util.Set;

import com.google.common.collect.Sets;
import com.google.inject.Inject;

import com.threerings.util.Resulting;

import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.server.PresentsDObjectMgr;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.data.PeeredPlayerInfo;
import com.threerings.orth.aether.server.AetherNodeAction;
import com.threerings.orth.aether.server.AetherNodeRequest;
import com.threerings.orth.aether.server.IgnoreManager;
import com.threerings.orth.aether.server.PeerEyeballer;
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

import com.threerings.signals.Listener1;

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

        // start listening to player updates from the vault
        _eyeballer.playerInfoChanged.connect(new EyeballListener());
    }

    public void configure (AetherClientObject player, PartyConfig config)
    {
        _partyObj.startTransaction();
        try {
            // setting up a brand new party, we have to add the creator as a peep
            addPlayer(player, true);
            // and make them the leader
            _partyObj.setLeaderId(player.getPlayerId());

        } finally {
            _partyObj.commitTransaction();
        }
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

    public PartyPeep getPeep (int playerId)
    {
        return (_partyObj != null) ? _partyObj.peeps.get(playerId) : null;
    }

    protected PartierObject getPartier (int partierId)
    {
        AuthName authName = NodeletAuthName.makeKey(PartyNodelet.class, partierId);
        return (PartierObject) _clientMgr.getClientObject(authName);
    }

    /**
     * Determine whether or not the given player has at least one friend in this party.
     */
    public boolean isPartyFriend (AetherClientObject player)
    {
        return player.containsOnlineFriend(getPlayerIds());
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
    protected PartyPeep buildPeep (AetherClientObject player)
    {
        PartyPeep peep = createPeep();
        peep.name = player.playerName;
        peep.joinOrder = nextJoinOrder();
        peep.connected = false;

        // get some data from the eyeballer
        PeeredPlayerInfo info = _eyeballer.getPlayerData(player.getPlayerId());
        if (info != null) {
            updatePeepFromEyeballer(info, peep);

        } else {
            log.warning("Erk, peep with no eyeballer info", "playerId", peep.getPlayerId());
        }

        return peep;
    }

    /**
     * Shutdown this party.
     */
    @Override
    public void shutdown ()
    {
        log.debug("Party Manager shutting down.", "partyId", _partyId, "peeps", _partyObj.peeps);

        // clear the party info from all remaining players' player objects
        for (PartyPeep peep : _partyObj.peeps) {
            endPartierSession(peep.name.getId());
        }
        _invMgr.clearDispatcher(_partyObj.partyService);
        _invMgr.clearDispatcher(_partyObj.partyChatService);

        super.shutdown();
    }

    /**
     * Called from a vault peer via a node action to add a player to our party, preparing for
     * their client to log in at which point the peep's status will flip to online.
     *
     * TODO: For simplicity, we currently accept a full AetherClientObject here, which means
     * we stream a ton of data from peer to peer. This is somewhere we could optimize easily
     * in the future.
     */
    public void addPlayer (final AetherClientObject player, boolean override) {
        boolean wasInvited = _invitedIds.remove(player.getPlayerId());
        if (override || wasInvited || _partyObj.policy == PartyPolicy.OPEN ||
            (_partyObj.policy == PartyPolicy.FRIENDS && isPartyFriend(player))) {
            if (_partyObj.peeps.containsKey(player.getPlayerId())) {
                log.warning("Attempting to add a player that's already in the party.",
                    "partyId", _partyId, "player", player);
                // but let it pass
                return;
            }
            doAddPeepToParty(buildPeep(player));
            return;
        }
        log.warning("Attempting to add and uninvited player to a closed group.",
            "partyId", _partyId, "player", player);
        throw new IllegalStateException(InvocationCodes.E_ACCESS_DENIED);
    }


    /**
     * Called from the access controller when subscription is approved for the specified player.
     */
    public void clientConnected (final PartierObject partier)
    {
        final PartyPeep peep = getPeep(partier.getPlayerId());
        if (peep == null) {
            // this likely just means they were booted in the time it took them to connect
            return;
        }

        // else hook them up with party info (not sure how useful this really is, but whatever)
        partier.setPartyId(_partyId);

        // finally show them as connected!
        peep.connected = true;
        _partyObj.updatePeeps(peep);
    }

    /**
     * Called from the access controller when a player's party connection is lost.
     */
    public void clientDisconnected (PlayerName name)
    {
        PartyPeep peep = getPeep(name.getId());
        if (peep != null) {
            // they disconnected but they're still in the party; note them offline
            peep.connected = false;
            _partyObj.updatePeeps(peep);
        }
    }

    @Override
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

    @Override
    public void leaveParty (PartierObject caller, InvocationService.InvocationListener listener)
        throws InvocationException
    {
        removePlayer(caller.getPlayerId());
    }

    @Override
    public void assignLeader (PartierObject caller, int playerId,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        requireLeader(caller);

        PartyPeep leader = getPeep(_partyObj.leaderId);
        PartyPeep peep = getPeep(playerId);
        if (peep == null || peep == leader || !peep.connected) {
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

    @Override
    public void updatePolicy (PartierObject caller, PartyPolicy policy,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        requireLeader(caller);
        _partyObj.setPolicy(policy);
    }

    @Override
    public void updateDisband (PartierObject caller, boolean disband,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        requireLeader(caller);
        _partyObj.setDisband(disband);
    }

    @Override
    public void invitePlayer (final PartierObject inviter, final PlayerName invitee,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        if (_partyObj.policy == PartyPolicy.CLOSED &&
            _partyObj.leaderId != inviter.getPlayerId()) {
            throw new InvocationException(PartyCodes.E_CANT_INVITE_CLOSED);
        }

        // if this party is in FRIENDS mode, we need to test friendship in the node request later
        final Set<Integer> mustContainFriend =
            (_partyObj.policy == PartyPolicy.FRIENDS) ? getPlayerIds() : null;

        if (_partyObj.peeps.containsKey(invitee.getKey())) {
            throw new InvocationException(PartyCodes.E_ALREADY_IN_PARTY);
        }

        if (!hasVacancies(1)) {
            throw new InvocationException(PartyCodes.E_PARTY_FULL);
        }

        // the invite can't go through if the recipient is not online
        if (null == _peerMgr.locatePlayer(invitee.getId())) {
            throw new InvocationException(AetherCodes.USER_NOT_ONLINE);
        }

        // make sure one of these folks isn't ignoring the other
        _ignoreMgr.validateCommunication(inviter.getPlayerId(), invitee.getId());

        final PartyInvite fInvite = createInvite(inviter.playerName, invitee);
        _peerMgr.invokeSingleNodeRequest(new AetherNodeRequest(invitee.getId()) {
                @Override protected void execute (AetherClientObject plobj,
                    InvocationService.ResultListener listener) {
                    fInvite.aetherInfusion(plobj);
                    // once on the invitee's aether peer, we can validate friendship
                    if (mustContainFriend != null &&
                        !plobj.containsOnlineFriend(mustContainFriend)) {
                        listener.requestFailed(PartyCodes.E_CANT_INVITE_CLOSED);
                        return;
                    }
                    CommSender.receiveComm(plobj, fInvite);
                    listener.requestProcessed(fInvite);
                }
            }, new Resulting<PartyInvite>(listener) {
            @Override public void requestCompleted (PartyInvite invite) {
                super.requestCompleted(invite);
                // add them to the invited set
                _invitedIds.add(invitee.getId());
                CommSender.receiveComm(inviter, invite);
            }
        }
        );
    }

    /**
     * Remove the specified player from the party.
     * @return true if they were removed.
     */
    public boolean removePlayer (int playerId)
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

    /**
     * Return the maximum number of players in a party, or zero for unlimited.
     */
    public int getMaxPartySize ()
    {
        return 0;
    }

    public boolean hasVacancies (int count)
    {
        int limit = getMaxPartySize();

        return (limit == 0) || _partyObj.peeps.size() + count <= limit;
    }

    protected PartyInvite createInvite (PlayerName inviter, PlayerName invitee)
    {
        return new PartyInvite(inviter, invitee, _nodelet);
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
     * This is the canonical place to add a peep to the party, so that subclasses can react
     * directly to the addition.
     */
    protected void doAddPeepToParty (PartyPeep peep)
    {
        _partyObj.addToPeeps(peep);
    }

    /**
     * Copy information from a {@link PeeredPlayerInfo} (or subclass thereof) into its
     * respective {@link PartyPeep} (or subclass thereof). Meant to be overriden.
     */
    protected void updatePeepFromEyeballer (PeeredPlayerInfo info, PartyPeep peep)
    {
        peep.guild = info.guildName;
        peep.whereabouts = info.whereabouts;
    }

    protected void endPartierSession (int playerId)
    {
        // just hop over to the vault and clear out the player's party
        _peerMgr.invokeNodeAction(new AetherNodeAction(playerId) {
            @Override protected void execute (AetherClientObject memobj) {
                memobj.setParty(null);
            }
        });
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

    protected class EyeballListener implements Listener1<PeeredPlayerInfo>
    {
        @Override public void apply (PeeredPlayerInfo info)
        {
            int playerId = info.authName.getId();
            PartyPeep peep = getPeep(playerId);
            // we only care about updates to one of our peeps
            if (peep != null) {
                updatePeepFromEyeballer(info, peep);
                _partyObj.updatePeeps(peep);
            }
        }
    }

    protected SpeakRouter _speakRouter;
    protected PartyObject _partyObj;
    protected int _partyId;

    protected Set<Integer> _invitedIds = Sets.newHashSet();

    @Inject protected PresentsDObjectMgr _omgr;
    @Inject protected ChatManager _chatMan;
    @Inject protected ClientManager _clientMgr;
    @Inject protected PeerEyeballer _eyeballer;
    @Inject protected IgnoreManager _ignoreMgr;
    @Inject protected InvocationManager _invMgr;
    @Inject protected OrthPeerManager _peerMgr;
}
