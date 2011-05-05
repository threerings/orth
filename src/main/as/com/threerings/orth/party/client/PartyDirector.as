//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client {
import flash.utils.Dictionary;

import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import mx.core.UIComponent;

import org.osflash.signals.Signal;

import com.threerings.flex.CommandMenu;
import com.threerings.whirled.data.Scene;

import com.threerings.util.DelayUtil;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.Util;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ResultAdapter;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.EventAdapter;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.ObjectAccessError;
import com.threerings.presents.util.SafeSubscriber;

import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.locus.client.LocusDirector;
import com.threerings.orth.notify.client.NotificationDirector;
import com.threerings.orth.notify.data.Notification;
import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyBoardMarshaller;
import com.threerings.orth.party.data.PartyBootstrapData;
import com.threerings.orth.party.data.PartyCodes;
import com.threerings.orth.party.data.PartyDetail;
import com.threerings.orth.party.data.PartyObject;
import com.threerings.orth.party.data.PartyPeep;
import com.threerings.orth.room.data.RoomLocus;

/**
 * Manages party stuff on the client.
 */
public class PartyDirector extends BasicDirector
{
    // Hard reference some classes
    PartyBoardMarshaller;
    PartyAuthName;
    PartyObject;

    public const log :Log = Log.getLog(this);

    public const partyJoined :Signal = new Signal();
    public const partyLeft :Signal = new Signal();

    /**
     * Format the specified Label or TextInput to have the right status.
     * Fucking Flex has no interface implemented by both.
     */
    public static function formatStatus (label :UIComponent, status :String, statusType :int) :void
    {
        var color :uint;
        switch (statusType) {
        default:
            color = 0x22668d;
            break;

        case PartyCodes.STATUS_TYPE_LOBBY:
            color = 0x426733;
            break;

        case PartyCodes.STATUS_TYPE_USER:
            color = 0x666666;
            break;
        }
        label.setStyle("color", color);
        label.setStyle("disabledColor", color);
        Object(label).text = Msgs.PARTY.get("m.status_" + statusType, status);
    }

    public function PartyDirector ()
    {
        super(_octx);

        _notDir.notificationName = PartyObject.NOTIFICATION;
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

    public function getPartyId () :int
    {
        return (_partyObj == null) ? 0 : _partyObj.id;
    }

    public function getPartySize () :int
    {
        return (_partyObj == null) ? 0 : _partyObj.peeps.size();
    }

    public function isInParty () :Boolean
    {
        return (0 != getPartyId());
    }

    public function isPartyLeader () :Boolean
    {
        return (_partyObj != null) && (_partyObj.leaderId == _octx.getMyId());
    }

    /**
     * Create either a party board popup, or a party popup if we're already in a party.
     */
    //public function createAppropriatePartyPanel () :FloatingPanel
    //{
    //    if (_partyObj != null) {
    //        var panel :PartyPanel = new PartyPanel(_partyObj);
    //        return panel;
    //    }
    //    return new PartyBoardPanel();
    //}

    // TODO(bruno): UI
    public function popPeepMenu (peep :PartyPeep, partyId :int) :void
    {
        //var menuItems :Array = [];

        ////_orthCtrl.addMemberMenuItems(peep.name, menuItems, false);

        //if (_partyObj != null && partyId == _partyObj.id) {
        //    const peepId :int = peep.name.getId();
        //    const ourId :int = _octx.getMyId();
        //    if (_partyObj.leaderId == ourId && peepId != ourId) {
        //        CommandMenu.addSeparator(menuItems);
        //        menuItems.push({ label: Msgs.PARTY.get("b.boot"),
        //                         callback: bootPlayer, arg: peep.name.getId() });
        //        menuItems.push({ label: Msgs.PARTY.get("b.assign_leader"),
        //                         callback: assignLeader, arg: peep.name.getId() });
        //    }
        //}

        //CommandMenu.createMenu(menuItems, _topPanel).popUpAtMouse();
    }

    public function getPartyObject () :PartyObject
    {
        return _partyObj;
    }

    /**
     * Get the party board.
     */
    public function getPartyBoard (
        resultHandler :Function, mode :int = PartyCodes.BOARD_NORMAL) :void
    {
        _pbsvc.getPartyBoard(mode, _octx.resultListener(resultHandler, OrthCodes.PARTY_MSGS));
    }

    /**
     * Request info on the specified party. Results will be displayed in a popup.
     */
    public function getPartyDetail (partyId :int) :void
    {
        if (Boolean(_detailRequests[partyId])) {
            return; // suppress requests that are already outstanding
        }
        _detailRequests[partyId] = true;
        var handleFailure :Function = function (error :String) :void {
            delete _detailRequests[partyId];
            _octx.displayFeedback(OrthCodes.PARTY_MSGS, error);
        };
        _pbsvc.getPartyDetail(partyId, new ResultAdapter(gotPartyDetail, handleFailure));
    }

    /**
     * Create a new party.
     */
    public function createParty (name :String, inviteAllFriends :Boolean) :void
    {
        var handleSuccess :Function = function (partyId :int, host :String, port :int) :void {
            connectParty(partyId, host, port);
        };
        var handleFailure :Function = function (error :String) :void {
            // TODO(bruno)
            //_octx.displayFeedback(OrthCodes.PARTY_MSGS, error);
            //// re-open...
            //var panel :CreatePartyPanel = new CreatePartyPanel();
            //panel.open();
            //panel.init(name, inviteAllFriends);
        };
        _pbsvc.createParty(name, inviteAllFriends, new JoinAdapter(handleSuccess, handleFailure));
    }

    /**
     * Join a party.
     */
    public function joinParty (id :int) :void
    {
        if (isInParty()) {
            if (getPartyId() == id) {
                return; // nuffin' doin'
            }
            clearParty();
        }

        // first we have to find out what node is hosting the party in question
        _pbsvc.locateParty(id,
            new JoinAdapter(connectParty, function (cause :String) :void {
                _octx.displayFeedback(OrthCodes.PARTY_MSGS, cause);
            }));
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
            _partyObj.removeListener(_partyListener);
            _partyListener = null;
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
        _partyObj.partyService.invitePlayer(memberId, _octx.listener(OrthCodes.PARTY_MSGS));
    }

    // from BasicDirector
    override public function clientDidLogoff (event :ClientEvent) :void
    {
        super.clientDidLogoff(event);

        if (!event.isSwitchingServers()) {
            clearParty();
        }
    }

    protected function checkFollowScene () :void
    {
        if (_partyObj.sceneId != 0) {
            _locusDir.moveTo(new RoomLocus(_partyObj.sceneId));
        }
    }

    protected function partyDidLogon (event :ClientEvent) :void
    {
        var pbd :PartyBootstrapData = (event.getClient().getBootstrapData() as PartyBootstrapData);
        _safeSubscriber = new SafeSubscriber(pbd.partyOid, gotPartyObject, subscribeFailed);
        _safeSubscriber.subscribe(_pctx.getDObjectManager());
    }

    protected function partyLogonFailed (event :ClientEvent) :void
    {
        log.warning("Failed to logon to party server", "cause", event.getCause());
        _octx.displayFeedback(OrthCodes.PARTY_MSGS, event.getCause().message);
    }

    protected function partyConnectFailed (event :ClientEvent) :void
    {
        var cause :Error = event.getCause();
        log.warning("Lost connection to party server", cause);

        // we need to clear out our party stuff manually since everything was dropped
        _safeSubscriber = null;
        _partyListener = null;
        _partyObj = null;
        _pctx = null;
        clearParty(); // clear the rest

        // report via locus chat that we lost our party connection
        if (cause != null) {
            _octx.displayFeedback(OrthCodes.PARTY_MSGS,
                MessageBundle.tcompose("e.lost_party", cause.message));
        }
    }

    protected function connectParty (partyId :int, hostname :String, port :int) :void
    {
        // we are joining a party- close all detail panels
        closeAllDetailPanels();

        // create a new party session and connect to our party host node
        _pctx = new PartyContextImpl(_module);
        _pctx.getClient().addClientObserver(new ClientAdapter(
            null, partyDidLogon, null, null, partyLogonFailed, partyConnectFailed));
        _pctx.connect(partyId, hostname, port);
    }

    /**
     * Called if our safe subscriber has succeeded in getting the party object.
     */
    protected function gotPartyObject (obj :PartyObject) :void
    {
        _partyObj = obj;
        _partyListener = new EventAdapter();
        _partyListener.attributeChanged = partyAttrChanged;
        _partyListener.messageReceived = partyMsgReceived;
        _partyListener.objectDestroyed = Util.adapt(clearParty);
        _partyObj.addListener(_partyListener);


        partyJoined.dispatch();

        // we might need to warp to the party location
        checkFollowScene();
    }

    /**
     * Callback for a getPartyDetail request.
     */
    protected function gotPartyDetail (detail :PartyDetail) :void
    {
        // stop tracking that we have an outstanding request
        delete _detailRequests[detail.info.id];

        // close any previous detail panel for this party
        //var panel :PartyDetailPanel = _detailPanels[detail.info.id] as PartyDetailPanel;
        //if (panel != null) {
        //    panel.close();
        //}

        //// pop open the new one
        //panel = new PartyDetailPanel(detail);
        //_detailPanels[detail.info.id] = panel;
        //panel.addCloseCallback(function () :void {
        //    delete _detailPanels[detail.info.id];
        //});
        //panel.open();
    }

    protected function closeAllDetailPanels () :void
    {
        // TODO(bruno): UI
        //for each (var panel :PartyDetailPanel in Util.values(_detailPanels)) {
        //    panel.close();
        //}
    }

    /**
     * Called when we've failed to subscribe to a party.
     */
    protected function subscribeFailed (oid :int, cause :ObjectAccessError) :void
    {
        log.warning("Party subscription failed", "cause", cause);
        clearParty();
    }

    /**
     * Handles changes on the party object.
     */
    protected function partyAttrChanged (event :AttributeChangedEvent) :void
    {
        switch (event.getName()) {
        case PartyObject.SCENE_ID:
            checkFollowScene();
            break;

        case PartyObject.LEADER_ID:
            var newLeader :PartyPeep = _partyObj.peeps.get(event.getValue()) as PartyPeep;
            if (newLeader != null) {
                _notDir.addGenericNotification(
                    MessageBundle.tcompose("m.party_leader", newLeader.name.toString()),
                    Notification.PERSONAL);
            }
            break;
        }
    }

    /**
     * Handles messages on the party object.
     */
    protected function partyMsgReceived (event :MessageEvent) :void
    {
        //switch (event.getName()) {
        //case PartyObject.NOTIFICATION:
        //    _notDir.addNotification(Notification(event.getArgs()[0]));
        //    break;
        //}
    }

    // from BasicDirector
    override protected function clientObjectUpdated (client :Client) :void
    {
        super.clientObjectUpdated(client);

        if (_octx.getPlayerObject() != null) {
            var assignedPartyId :int = _octx.getPlayerObject().partyId;
            if (assignedPartyId != 0) {
                // join it!
                DelayUtil.delayFrame(joinParty, [ assignedPartyId ]);
            }
        }
    }

    // from BasicDirector
    override protected function registerServices (client :Client) :void
    {
        super.registerServices(client);

        client.addServiceGroup(OrthCodes.PARTY_GROUP);
    }

    // from BasicDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);

        _pbsvc = (client.requireService(PartyBoardService) as PartyBoardService);
    }

    protected var _module :Module = inject(Module);

    protected var _notDir :NotificationDirector = inject(NotificationDirector);
    protected var _locusDir :LocusDirector = inject(LocusDirector);

    protected var _octx :OrthContext = inject(OrthContext);

    protected var _pbsvc :PartyBoardService;

    protected var _pctx :PartyContextImpl;
    protected var _partyObj :PartyObject;
    protected var _safeSubscriber :SafeSubscriber;

    protected var _detailRequests :Dictionary = new Dictionary();
    protected var _detailPanels :Dictionary = new Dictionary();

    protected var _partyListener :EventAdapter;
}
}

import com.threerings.presents.client.InvocationAdapter;

import com.threerings.orth.party.client.PartyBoardService_JoinListener;

class JoinAdapter extends InvocationAdapter
    implements PartyBoardService_JoinListener
{
    public function JoinAdapter (foundFunc :Function, failedFunc :Function)
    {
        super(failedFunc);
        _foundFunc = foundFunc;
    }

    public function foundParty (partyId :int, hostname :String, port :int) :void
    {
        _foundFunc(partyId, hostname, port);
    }

    protected var _foundFunc :Function;
}
