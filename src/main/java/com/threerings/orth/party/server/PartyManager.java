//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import com.google.inject.Inject;
import com.google.inject.Provider;

import com.samskivert.util.ResultListener;
import com.samskivert.util.StringUtil;

import com.threerings.util.Resulting;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.ObjectDeathListener;
import com.threerings.presents.dobj.ObjectDestroyedEvent;
import com.threerings.presents.dobj.RootDObjectManager;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.Log;
import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.server.AetherNodeRequest;
import com.threerings.orth.comms.data.CommSender;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyCodes;
import com.threerings.orth.party.data.PartyInvite;
import com.threerings.orth.party.data.PartyMarshaller;
import com.threerings.orth.party.data.PartyObject;
import com.threerings.orth.party.data.PartyObjectAddress;
import com.threerings.orth.party.data.PartyPeep;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.server.OrthDeploymentConfig;

/**
 * Manages a particular party, living on a single node.
 */
public class PartyManager
    implements PartyProvider
{
    public final PartyObjectAddress addr;

    @Inject public PartyManager (RootDObjectManager omgr, InvocationManager invMgr,
        OrthDeploymentConfig conf, AetherClientObject creator, PartyObject partyObj)
    {
        _omgr = omgr;
        _invMgr = invMgr;

        // set up the new PartyObject
        _partyObj = partyObj;
        configurePartyObject(creator);
        _omgr.registerObject(_partyObj);

        addr = new PartyObjectAddress(conf.getPartyHost(), conf.getPartyPort(), _partyObj.getOid());

        // "invite" the creator
        _partyObj.invitedIds.add(_partyObj.leaderId);
    }

    /**
     * Fill in info on the party object.
     */
    protected void configurePartyObject (AetherClientObject creator)
    {
        _partyObj.leaderId = creator.getPlayerId();
        _partyObj.disband = true;
        _partyObj.setAccessController(new PartyAccessController(this));
        _partyObj.partyService = _invMgr.registerProvider(this, PartyMarshaller.class);
    }

    protected PartyPeep createPartyPeep (PartierObject partier, AppearanceInfo appearanceInfo)
    {
        PartyPeep peep = _peepProvider.get();
        peep.name = partier.playerName;
        peep.joinOrder = nextJoinOrder();
        return peep;
    }

    /**
     * Shutdown this party.
     */
    public void shutdown ()
    {
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
    public void clientSubscribed (final PartierObject partier)
    {
        final int playerId = partier.getPlayerId();

        // clear their invites to this party, if any
        _partyObj.invitedIds.remove(playerId);

        _peerMgr.invokeSingleNodeRequest(createPartyClientSubscribedRequest(playerId, addr),
            new ResultListener<AppearanceInfo>() {
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
                PartyPeep peep = createPartyPeep(partier, result);
                if (!_partyObj.peeps.contains(peep)) {
                    _partyObj.addToPeeps(peep);
                }
            }

            @Override public void requestFailed (Exception cause) {
                // TODO - notify the client that we done fucked up
                endPartierSession(playerId);
            }});
    }

    protected PartyClientSubscribedRequest createPartyClientSubscribedRequest (int playerId,
        PartyObjectAddress addr)
    {
        return new PartyClientSubscribedRequest(playerId, addr);
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
    public void updateRecruitment (PartierObject caller, byte recruitment,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        requireLeader(caller);
        _partyObj.setRecruitment(recruitment);
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
    public void invitePlayer (final PartierObject caller, PlayerName invitee,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        PartierObject inviter = caller;
        if (_partyObj.recruitment == PartyCodes.RECRUITMENT_CLOSED &&
            _partyObj.leaderId != inviter.getPlayerId()) {
            throw new InvocationException(PartyCodes.E_CANT_INVITE_CLOSED);
        }
        // add them to the invited set
        _partyObj.invitedIds.add(invitee.getId());

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
                CommSender.receiveComm(caller, invite);
            }
        });
    }

    protected PartyInvite createInvite (PartierObject inviter, PlayerName invitee)
    {
        return new PartyInvite(inviter.playerName.toOrthName(), invitee, addr);
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
        _peerMgr.invokeSingleNodeRequest(new AetherNodeRequest(playerId) {
            @Override protected void execute (AetherClientObject pl,
                InvocationService.ResultListener rl) {
                pl.setParty(null);
                rl.requestProcessed(null);
            }
        }, new Resulting<Void>("PartyClearer", Log.log, "playerId", playerId));
        PartySession session = (PartySession)_clmgr.getClient(PartyAuthName.makeKey(playerId));
        if (session != null) {
            session.endSession();
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

    protected static class PartyClientSubscribedRequest extends AetherNodeRequest
    {
        public PartyClientSubscribedRequest (int playerId, PartyObjectAddress addr)
        {
            super(playerId);
            _addr = addr;
        }

        @Override protected void execute (AetherClientObject player,
            InvocationService.ResultListener listener) {
            player.setParty(_addr);
            listener.requestProcessed(getAppearanceInfo(player));
        }

        /**
         * Returns appropriate party appearance info for the player.
         */
        protected AppearanceInfo getAppearanceInfo (AetherClientObject player)
        {
            return new AppearanceInfo();
        }

        protected PartyObjectAddress _addr;
    }

    /**
     * Captures any relevant info about a player's appearance to include in the party data.
     */
    protected static class AppearanceInfo
    {
    }

    protected final InvocationManager _invMgr;
    protected final RootDObjectManager _omgr;
    protected final PartyObject _partyObj;

    @Inject protected ClientManager _clmgr;
    @Inject protected OrthPeerManager _peerMgr;
    @Inject protected Provider<PartyPeep> _peepProvider;
}
