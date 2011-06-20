//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client {
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import org.osflash.signals.Signal;

import com.threerings.util.DelayUtil;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.Util;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ResultAdapter;
import com.threerings.presents.dobj.ObjectAccessError;
import com.threerings.presents.util.SafeSubscriber;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.locus.client.LocusDirector;
import com.threerings.orth.party.client.PartyRegistryDecoder;
import com.threerings.orth.party.client.PartyRegistryReceiver;
import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyCodes;
import com.threerings.orth.party.data.PartyObject;
import com.threerings.orth.party.data.PartyObjectAddress;
import com.threerings.orth.party.data.PartyRegistryMarshaller;

/**
 * Manages party stuff on the client.
 */
public class PartyDirector implements PartyRegistryReceiver
{
    // Hard reference some classes
    PartyRegistryMarshaller;
    PartyAuthName;
    PartyObject;

    public const invitationReceived :Signal = new Signal(PlayerName);
    public const partyJoined :Signal = new Signal();
    public const partyJoinFailed :Signal = new Signal(String);// signals the cause
    public const partyLeft :Signal = new Signal();

    public function PartyDirector ()
    {
        const client :Client = inject(AetherClient);
        client.getInvocationDirector().registerReceiver(new PartyRegistryDecoder(this));
        client.addEventListener(ClientEvent.CLIENT_DID_LOGON, function (..._) :void {
            _prsvc = client.requireService(PartyRegistryService);
            if (_octx.playerObject.party != null) {
                DelayUtil.delayFrame(joinParty, [ _octx.playerObject.party ]); // Join it!
            }
        });
    }

    public function receiveInvitation (inviter :PlayerName, location :PartyObjectAddress) :void
    {
        invitationReceived.dispatch(inviter);
    }

    /**
     * Can we invite people to our party?
     */
    public function canInviteToParty () :Boolean
    {
        return (_partyObj != null) &&
            ((_partyObj.recruitment == PartyCodes.RECRUITMENT_OPEN) || isPartyLeader());
    }

    public function partyContainsPlayer (memberId :int) :Boolean
    {
        return (_partyObj != null) && _partyObj.peeps.containsKey(memberId);
    }

    public function getPartySize () :int
    {
        return (_partyObj == null) ? 0 : _partyObj.peeps.size();
    }

    public function isInParty () :Boolean
    {
        return _partyObj != null;
    }

    public function isPartyLeader () :Boolean
    {
        return (_partyObj != null) && (_partyObj.leaderId == _octx.myId);
    }

    public function getPartyObject () :PartyObject
    {
        return _partyObj;
    }

    /**
     * Create a new party.
     */
    public function createParty () :void
    {
        _prsvc.createParty(new ResultAdapter(connectParty, partyJoinFailed.dispatch));
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
        _partyObj.partyService.assignLeader(memberId, _octx.listener(OrthCodes.PARTY_MSGS));
    }

    public function updateStatus (status :String) :void
    {
        _partyObj.partyService.updateStatus(status, _octx.listener(OrthCodes.PARTY_MSGS));
    }

    public function updateRecruitment (recruitment :int) :void
    {
        _partyObj.partyService.updateRecruitment(recruitment, _octx.listener(OrthCodes.PARTY_MSGS));
    }

    public function updateDisband (disband :Boolean) :void
    {
        _partyObj.partyService.updateDisband(disband, _octx.listener(OrthCodes.PARTY_MSGS));
    }

    /**
     * Leaves the current party.
     */
    public function bootPlayer (memberId :int) :void
    {
        _partyObj.partyService.bootPlayer(memberId, _octx.listener(OrthCodes.PARTY_MSGS));
    }

    public function invitePlayer (memberId :int) :void
    {
        if (isInParty()) {
            _partyObj.partyService.invitePlayer(memberId, _octx.listener(OrthCodes.PARTY_MSGS));
        } else {
            createParty();
            function onJoin (..._) :void {
                partyJoinFailed.remove(onJoinFailed);
                invitePlayer(memberId);
            }
            function onJoinFailed (..._) :void { partyJoined.remove(onJoin); }
            partyJoined.addOnce(onJoin);
            partyJoinFailed.addOnce(onJoinFailed);
        }
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
            _octx.displayFeedback(OrthCodes.PARTY_MSGS,
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
                partyJoinFailed.dispatch(event.getCause().message);
                _octx.displayFeedback(OrthCodes.PARTY_MSGS, event.getCause().message);
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

        partyJoined.dispatch();
    }

    /**
     * Called when we've failed to subscribe to a party.
     */
    protected function subscribeFailed (oid :int, cause :ObjectAccessError) :void
    {
        log.warning("Party subscription failed", "cause", cause);
        partyJoinFailed.dispatch(cause.message);
        clearParty();
    }

    protected const _module :Module = inject(Module);
    protected const _locusDir :LocusDirector = inject(LocusDirector);
    protected const _octx :OrthContext = inject(OrthContext);

    protected var _prsvc :PartyRegistryService;
    protected var _pctx :PartyContext;
    protected var _partyObj :PartyObject;
    protected var _safeSubscriber :SafeSubscriber;

    private static const log :Log = Log.getLog(PartyDirector);
}
}
