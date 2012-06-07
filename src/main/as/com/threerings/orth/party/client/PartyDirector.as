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

    public function connectToParty (party :HostedNodelet) :void
    {
        super.connect(party);
    }

    /**
     * Can we invite people to our party?
     */
    public function get canInviteToParty () :Boolean
    {
        return (_partyObj != null) &&
            ((_partyObj.policy == PartyPolicy.OPEN) || partyLeader);
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
            partyLeft.dispatch();
            _partyObj.destroyed.remove(disconnect);
            _partyObj = null;
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
            _aetherDir.createParty(function () :void {
                invitePlayer(invitee);
            }, Listeners.chatErrHandler(OrthCodes.PARTY_MSGS));
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

        // if we're joining a party that's in an intervention, joining them is not optional
        if (_partyObj.locus != null) {
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
    }

    public function locusChanged (newLocus :HostedLocus) :void
    {
        if (newLocus == null || (_locusDir.locus != null &&
                _locusDir.locus.equals(newLocus))) {
            return;
        }
        _locusDir.moveToHostedLocus(newLocus);
    }

    protected const _aetherDir :AetherDirector = inject(AetherDirector);
    protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);
    protected const _comms :CommsDirector = inject(CommsDirector);
    protected const _module :Module = inject(Module);
    protected const _locusDir :LocusDirector = inject(LocusDirector);

    protected var _partyObj :PartyObject;
    protected var _speakRouter :SpeakRouter;
    protected var _initialized :Boolean;

    private static const log :Log = Log.getLog(PartyDirector);
}
}
