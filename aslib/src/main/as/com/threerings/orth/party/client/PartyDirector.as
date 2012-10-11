//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.client {
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import org.osflash.signals.Signal;

import com.threerings.util.F;
import com.threerings.util.Log;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.dobj.DObject;

import com.threerings.orth.aether.client.AetherDirector;
import com.threerings.orth.aether.data.PartyMemberNotificationComm;
import com.threerings.orth.chat.client.DObjectSpeakRouter;
import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.SpeakRouter;
import com.threerings.orth.client.Listeners;
import com.threerings.orth.comms.client.CommsDirector;
import com.threerings.orth.comms.data.CommDecoder;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.client.LocusDirector;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.client.NodeletDirector;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyInvite;
import com.threerings.orth.party.data.PartyNodelet;
import com.threerings.orth.party.data.PartyObject;
import com.threerings.orth.party.data.PartyPeep;
import com.threerings.orth.party.data.PartyPolicy;
import com.threerings.orth.party.data.PartyRegistryMarshaller;

/**
 * Manages party stuff on the client.
 */
public class PartyDirector extends NodeletDirector
{
    // Hard reference some classes
    PartyRegistryMarshaller;
    PartyNodelet;
    PartierObject;
    PartyInvite;

    /** If isInitialized is false, this signal will trigger when we're fully logged on. */
    public const onReady :Signal = new Signal();

    public const partyJoined :Signal = new Signal();
    public const partyLeft :Signal = new Signal();
    public const partyLeaderChanged :Signal = new Signal();

    public function PartyDirector ()
    {
        // register receivers on the party client
        _ctx.getClient().getInvocationDirector().registerReceiver(new CommDecoder(_comms));
    }

    /** If this function returns false, onReady will be dispatched when we're logged on. */
    public function isInitialized () :Boolean
    {
        return _initialized;
    }

    public function aetherIsReady () :void
    {
        if (_initialized) {
            return;
        }
        _initialized = true;
        onReady.dispatch();
    }

    override protected function refreshPlayer () :void
    {
        super.refreshPlayer();

        if (_plobj != null) {
            // if our authoritative party address changes, follow it
            _plobj.partyChanged.add(connectToParty);

            if (_plobj.party != null) {
                connectToParty(_plobj.party);

            } else {
                disconnect();
                aetherIsReady();
            }
        }

        function connectToParty (party :HostedNodelet, oldParty :HostedNodelet = null) :void {
            connect(party);
        }
    }

    /**
     * Can we invite people to our party?
     */
    public function get canInviteToParty () :Boolean
    {
        return (_partyObj != null) && (partyLeader ||
            (_partyObj.policy == PartyPolicy.OPEN) ||
            (_partyObj.policy == PartyPolicy.FRIENDS &&
                _aetherDir.aetherObj.containsOnlineFriend(getPlayerIds())));
    }

    public function partyContainsPlayer (memberId :int) :Boolean
    {
        return (_partyObj != null) && _partyObj.peeps.containsKey(memberId);
    }

    public function get partySize () :int
    {
        return (_partyObj == null) ? 0 : _partyObj.peeps.size();
    }

    public function get locus () :Locus
    {
        return (_partyObj != null && _partyObj.locus != null) ? _partyObj.locus.locus : null;
    }

    public function get inParty () :Boolean
    {
        return _partyObj != null;
    }

    public function get partyLeader () :Boolean
    {
        return (_partyObj != null) && (_partyObj.leaderId == _octx.myId);
    }

    public function get partyObject () :PartyObject
    {
        return _partyObj;
    }

    public function getPlayerIds (onlineOnly :Boolean = false) :Array
    {
        return F.map(getPeeps(onlineOnly), function (peep :PartyPeep) :int {
            return peep.id;
        });
    }

    public function getPeeps (onlineOnly :Boolean = false) :Array
    {
        var peeps :Array = (partyObject != null) ? partyObject.peeps.toArray() : [];
        if (onlineOnly) {
            peeps = F.filter(peeps, function (peep :PartyPeep) :Boolean {
                return peep.connected;
            });
        }
        return F.map(peeps, function (peep :PartyPeep) :int { return peep.name.id; });
    }

    /**
     * Clear/leave the current party, if any.
     */
    public function leaveParty () :void
    {
        if (_partyObj != null) {
            _partyObj.partyService.leaveParty(Listeners.listener());
        }
        disconnect();
    }

    override public function clientDidLogoff (event :ClientEvent) :void
    {
        super.clientDidLogoff(event);

        if (_partyObj != null) {
            _partyObj.destroyed.remove(disconnect);
            _partyObj = null;
            partyLeft.dispatch();
        }
    }

    public function assignLeader (memberId :int) :void
    {
        _partyObj.partyService.assignLeader(memberId, Listeners.listener(OrthCodes.PARTY_MSGS));
    }

    public function updatePolicy (policy :PartyPolicy) :void
    {
        _partyObj.partyService.updatePolicy(policy, Listeners.listener(OrthCodes.PARTY_MSGS));
    }

    public function updateDisband (disband :Boolean) :void
    {
        _partyObj.partyService.updateDisband(disband, Listeners.listener(OrthCodes.PARTY_MSGS));
    }

    /**
     * Leaves the current party.
     */
    public function bootPlayer (memberId :int) :void
    {
        _partyObj.partyService.bootPlayer(memberId, Listeners.listener(OrthCodes.PARTY_MSGS));
    }

    public function moveParty (locus :HostedLocus) :void
    {
        _partyObj.partyService.moveParty(locus, Listeners.listener(OrthCodes.PARTY_MSGS));
    }

    public function invitePlayer (invitee :PlayerName) :void
    {
        if (inParty) {
            _partyObj.partyService.invitePlayer(invitee, Listeners.listener(OrthCodes.PARTY_MSGS));
        } else {
            if (_pendingInvites.length == 0) {
                // we have no party and we've not already sent off a creation request; do so
                _aetherDir.createParty(null, Listeners.chatErrHandler(OrthCodes.PARTY_MSGS));
            }
            _pendingInvites.push(invitee);
        }
    }

    /**
     * Called if our safe subscriber has succeeded in getting the party object.
     */
    override protected function objectAvailable (obj :DObject) :void
    {
        super.objectAvailable(obj);

        _partyObj = PartyObject(obj);
        _partyObj.destroyed.add(disconnect);

        // respond to future locus changes
        _partyObj.locusChanged.add(locusChanged);

        // signal changes to party leadership
        _partyObj.leaderIdChanged.add(F.callback(partyLeaderChanged.dispatch));

        _partyObj.peepsEntryAdded.add(peepAdded);
        _partyObj.peepsEntryRemoved.add(peepRemoved);

        // if we're joining a party that's collectivey in a specific locus, we must go there
        if (_partyObj.locus != null && !_partyObj.locus.locus.equals(_aetherDir.aetherObj.locus)) {
            _locusDir.moveToHostedLocus(_partyObj.locus);
        }

        _module.inject(function () :void {
            _speakRouter = new DObjectSpeakRouter(_partyObj, _partyObj.partyChatService);
        });
        _chatDir.registerRouter(OrthChatCodes.PARTY_CHAT_TYPE, _speakRouter);

        partyJoined.dispatch();

        // if we had not flagged ourselves as initialized yet, we certainly are now
        if (!isInitialized()) {
            aetherIsReady();
        }

        for each (var invitee :PlayerName in _pendingInvites) {
            _partyObj.partyService.invitePlayer(invitee, Listeners.listener(OrthCodes.PARTY_MSGS));
        }
        _pendingInvites = [];
    }

    public function locusChanged (newLocus :HostedLocus) :void
    {
        if (newLocus == null || (_locusDir.locus != null &&
                _locusDir.locus.equals(newLocus))) {
            return;
        }
        _locusDir.moveToHostedLocus(newLocus);
    }

    protected function peepAdded (entry :PartyPeep) :void
    {
        if (entry.name.id == _octx.myId) {
            // the server should already have added us prior to subscription
            log.warning("Local player added to party, weird");
        } else {
            notify(entry, PartyMemberNotificationComm.NOTE_JOIN);
        }
    }

    protected function peepRemoved (entry :PartyPeep) :void
    {
        notify(entry, PartyMemberNotificationComm.NOTE_LEAVE);
    }

    protected function notify (entry :PartyPeep, event :int) :void
    {
        _commsDir.receiveComm(new PartyMemberNotificationComm(
            entry.name, _aetherDir.aetherObj.playerName, event));
    }

    protected const _aetherDir :AetherDirector = inject(AetherDirector);
    protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);
    protected const _comms :CommsDirector = inject(CommsDirector);
    protected const _module :Module = inject(Module);
    protected const _locusDir :LocusDirector = inject(LocusDirector);
    protected const _commsDir :CommsDirector = inject(CommsDirector);

    protected var _partyObj :PartyObject;
    protected var _speakRouter :SpeakRouter;
    protected var _initialized :Boolean;
    protected var _pendingInvites :Array = [];

    private static const log :Log = Log.getLog(PartyDirector);
}
}
