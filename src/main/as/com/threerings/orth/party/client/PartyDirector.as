//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client {
import com.threerings.orth.client.Listeners;

import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import org.osflash.signals.Signal;

import com.threerings.util.DelayUtil;
import com.threerings.util.F;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ResultAdapter;
import com.threerings.presents.dobj.ObjectAccessError;
import com.threerings.presents.util.SafeSubscriber;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.comms.client.CommsDirector;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.client.LocusDirector;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyCodes;
import com.threerings.orth.party.data.PartyInvite;
import com.threerings.orth.party.data.PartyObject;
import com.threerings.orth.party.data.PartyObjectAddress;
import com.threerings.orth.party.data.PartyPeep;
import com.threerings.orth.party.data.PartyRegistryMarshaller;

/**
 * Manages party stuff on the client.
 */
public class PartyDirector
{
    // Hard reference some classes
    PartyRegistryMarshaller;
    PartyAuthName;
    PartyObject;
    PartyInvite;

    public const partyJoined :Signal = new Signal();
    public const partyLeft :Signal = new Signal();

    public function PartyDirector ()
    {
        const client :Client = inject(AetherClient);
        client.addEventListener(ClientEvent.CLIENT_DID_LOGON, function (..._) :void {
            _prsvc = client.requireService(PartyRegistryService);
            if (_octx.aetherObject.party != null) {
                DelayUtil.delayFrame(joinParty, [ _octx.aetherObject.party ]); // Join it!
            }
        });
    }

    /**
     * Can we invite people to our party?
     */
    public function get canInviteToParty () :Boolean
    {
        return (_partyObj != null) &&
            ((_partyObj.recruitment == PartyCodes.RECRUITMENT_OPEN) || partyLeader);
    }

    public function partyContainsPlayer (memberId :int) :Boolean
    {
        return (_partyObj != null) && _partyObj.peeps.containsKey(memberId);
    }

    public function get partySize () :int
    {
        return (_partyObj == null) ? 0 : _partyObj.peeps.size();
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
        _prsvc.createParty(new ResultAdapter(connectParty, onJoinFailed));
    }

    /**
     * Join a party.
     */
    public function joinParty (address :PartyObjectAddress) :void
    {
        clearParty(); // Drop the old one if there is one
        connectParty(address);
    }

    /**
     * Clear/leave the current party, if any.
     */
    public function clearParty () :void
    {
        if (_safeSubscriber != null) {
            _safeSubscriber.unsubscribe(_pctx.getDObjectManager());
            _safeSubscriber = null;
        }
        if (_partyObj != null) {
            _partyObj.destroyed.remove(clearParty);
            _partyObj = null;
            partyLeft.dispatch();
        }
        if (_pctx != null) {
            _pctx.getClient().logoff(false);
            _pctx = null;
        }
    }

    public function assignLeader (memberId :int) :void
    {
        _partyObj.partyService.assignLeader(memberId, Listeners.listener(OrthCodes.PARTY_MSGS));
    }

    public function updateStatus (status :String) :void
    {
        _partyObj.partyService.updateStatus(status, Listeners.listener(OrthCodes.PARTY_MSGS));
    }

    public function updateRecruitment (recruitment :int) :void
    {
        _partyObj.partyService.updateRecruitment(recruitment, Listeners.listener(OrthCodes.PARTY_MSGS));
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
            createParty();
            _onJoin = F.callback(invitePlayer, invitee);
            partyJoined.addOnce(_onJoin);
        }
    }

    protected function onJoinFailed () :void
    {
        partyJoined.remove(_onJoin);
    }

    protected function partyConnectFailed (event :ClientEvent) :void
    {
        var cause :Error = event.getCause();
        log.warning("Lost connection to party server", cause);

        // we need to clear out our party stuff manually since everything was dropped
        _safeSubscriber = null;
        if (_partyObj != null) {
            partyLeft.dispatch();
        }
        _partyObj = null;
        _pctx = null;

        // report via locus chat that we lost our party connection
        if (cause != null) {
            Listeners.displayFeedback(OrthCodes.PARTY_MSGS,
                MessageBundle.tcompose("e.lost_party", cause.message));
        }
    }

    protected function connectParty (address :PartyObjectAddress) :void
    {
        // create a new party session and connect to our party host node
        _pctx = _module.getInstance(PartyContext);
        var client :Client = _pctx.getClient();
        client.addEventListener(ClientEvent.CLIENT_DID_LOGON, function (..._) :void {
            _safeSubscriber = new SafeSubscriber(address.oid, gotPartyObject, subscribeFailed);
            _safeSubscriber.subscribe(_pctx.getDObjectManager());
        });
        client.addEventListener(ClientEvent.CLIENT_FAILED_TO_LOGON,
            function (event :ClientEvent) :void {
                log.warning("Failed to logon to party server", "cause", event.getCause());
                onJoinFailed();
                Listeners.displayFeedback(OrthCodes.PARTY_MSGS, event.getCause().message);
        });
        client.addEventListener(ClientEvent.CLIENT_CONNECTION_FAILED, partyConnectFailed);
        _pctx.connect(address);
    }

    /**
     * Called if our safe subscriber has succeeded in getting the party object.
     */
    protected function gotPartyObject (obj :PartyObject) :void
    {
        _partyObj = obj;
        _partyObj.destroyed.add(clearParty);

        _partyObj.locusChanged.add(locusChanged);

        partyJoined.dispatch();
    }

    /**
     * Called when we've failed to subscribe to a party.
     */
    protected function subscribeFailed (oid :int, cause :ObjectAccessError) :void
    {
        log.warning("Party subscription failed", "cause", cause);
        onJoinFailed();
        clearParty();
    }

    public function locusChanged (newLocus :HostedLocus) :void
    {
        if (newLocus == null || _locusDir.locus.equals(newLocus)) { return; }
        _locusDir.moveToHostedLocus(newLocus);
    }

    protected const _module :Module = inject(Module);
    protected const _locusDir :LocusDirector = inject(LocusDirector);
    protected const _octx :OrthContext = inject(OrthContext);
    protected const _comms :CommsDirector = inject(CommsDirector);

    protected var _prsvc :PartyRegistryService;
    protected var _pctx :PartyContext;
    protected var _partyObj :PartyObject;
    protected var _safeSubscriber :SafeSubscriber;
    protected var _onJoin :Function;

    private static const log :Log = Log.getLog(PartyDirector);
}
}
