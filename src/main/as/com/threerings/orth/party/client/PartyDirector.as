//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.client {
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import org.osflash.signals.Signal;

import com.threerings.util.DelayUtil;
import com.threerings.util.F;
import com.threerings.util.Log;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ResultAdapter;
import com.threerings.presents.dobj.DObject;

import com.threerings.orth.aether.client.AetherClient;
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
import com.threerings.orth.party.data.PartyConfig;
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
        // we can't use BasicDirector's fancyness; it's hooked up to the Nodelet client
        const client :Client = inject(AetherClient);
        client.addEventListener(ClientEvent.CLIENT_DID_LOGON, function (..._) :void {
            _prsvc = client.requireService(PartyRegistryService);
            if (_octx.aetherObject.party != null) {
                DelayUtil.delayFrame(joinParty, [ _octx.aetherObject.party ]); // Join it!
            } else {
                didInitialize();
            }
        });
    }

    /** If this function returns false, onReady will be dispatched when we're logged on. */
    public function isInitialized () :Boolean
    {
        return _initialized;
    }

    protected function didInitialize () :void
    {
        _initialized = true;
        onReady.dispatch();
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

    public function get partierIds () :Array //<int>
    {
        return F.map(partyObject.peeps.toArray(),
            function (peep :PartyPeep) :int { return peep.name.id; });
    }

    /**
     * Create a new party.
     */
    public function createParty () :void
    {
        _prsvc.createParty(new PartyConfig(),
            new ResultAdapter(connectParty, F.adapt(onJoinFailed)));
    }

    /**
     * Join a party.
     */
    public function joinParty (hosted :HostedNodelet) :void
    {
        clearParty(); // Drop the old one if there is one
        connectParty(hosted);
    }

    /**
     * Clear/leave the current party, if any.
     */
    public function clearParty () :void
    {
        if (_partyObj != null) {
            _partyObj.destroyed.remove(clearParty);
            _partyObj = null;
            partyLeft.dispatch();
        }
        disconnect();
    }

    public function assignLeader (memberId :int) :void
    {
        _partyObj.partyService.assignLeader(memberId, Listeners.listener(OrthCodes.PARTY_MSGS));
    }

    public function updateStatus (status :String) :void
    {
        _partyObj.partyService.updateStatus(status, Listeners.listener(OrthCodes.PARTY_MSGS));
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
            _onJoin = F.callback(invitePlayer, invitee, Listeners.listener(OrthCodes.PARTY_MSGS));
            partyJoined.addOnce(_onJoin);
            createParty();
        }
    }

    protected function onJoinFailed () :void
    {
        partyJoined.remove(_onJoin);
    }

    protected function connectParty (address :HostedNodelet) :void
    {
        super.connect(address);
    }

    /**
     * Called if our safe subscriber has succeeded in getting the party object.
     */
    override protected function objectAvailable (obj :DObject) :void
    {
        super.objectAvailable(obj);
        
        _partyObj = PartyObject(obj);
        _partyObj.destroyed.add(clearParty);

        _partyObj.locusChanged.add(locusChanged);

        _ctx.getClient().getInvocationDirector().registerReceiver(new CommDecoder(_comms));

        _module.inject(function () :void {
            _speakRouter = new DObjectSpeakRouter(_partyObj, _partyObj.partyChatService);
        });
        _chatDir.registerRouter(OrthChatCodes.PARTY_CHAT_TYPE, _speakRouter);

        partyJoined.dispatch();

        // if we had not flagged ourselves as initialized yet, we certainly are now
        if (!isInitialized()) {
            didInitialize();
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

    protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);
    protected const _comms :CommsDirector = inject(CommsDirector);
    protected const _module :Module = inject(Module);
    protected const _locusDir :LocusDirector = inject(LocusDirector);

    protected var _prsvc :PartyRegistryService;
    protected var _partyObj :PartyObject;
    protected var _speakRouter :SpeakRouter;
    protected var _onJoin :Function;
    protected var _initialized :Boolean;

    private static const log :Log = Log.getLog(PartyDirector);
}
}
