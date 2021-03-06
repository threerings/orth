//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.client {
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.utils.ByteArray;

import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.util.F;
import com.threerings.util.ObjectMarshaller;
import com.threerings.util.ValueEvent;

import com.threerings.presents.dobj.AttributeChangeAdapter;
import com.threerings.presents.dobj.AttributeChangedEvent;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.whirled.data.SceneUpdate;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.client.Listeners;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.client.BootablePlaceController;
import com.threerings.orth.room.client.updates.UpdateAction;
import com.threerings.orth.room.client.updates.UpdateStack;
import com.threerings.orth.room.data.ActorInfo;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityMemories;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthRoomObject;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.SocializerInfo;

/**
 * Manages the various interactions that take place in a room scene.
 */
public class RoomObjectController extends RoomController
    implements BootablePlaceController
{
    // documentation inherited
    override protected function createRoomView () :RoomView
    {
        return _roomObjectView = new RoomObjectView(_rctx, this);
    }

    // from interface BootablePlaceController
    public function canBoot () :Boolean
    {
        return canManageRoom();
    }

    public function bootPlayer (playerId :int) :void
    {
        // This requires a service invocation, and must be implemented by a concrete subclass.
    }

    /**
     * Is the specified player in this room?
     */
    public function containsPlayer (name :PlayerName) :Boolean
    {
        var info :OccupantInfo = _roomObj.getOccupantInfo(name);
        return (info != null);
    }

    /**
     * Set the specified name hovered or unhovered.
     */
    public function setHoverName (name :PlayerName, hovered :Boolean) :void
    {
        setHoverSprite(hovered ? _roomObjectView.getOccupantByName(name) : null);
        _suppressNormalHovering = hovered;
    }

    override public function getViewerName (instanceId :int = 0) :String
    {
        var name :String = super.getViewerName(instanceId);
        if (name == null) {
            // look for the name in the OccupantInfos
            var info :SocializerInfo = findOccupantById(instanceId);
            if (info != null) {
                name = info.username.toString();
            }
        }
        return name;
    }

    /**
     * Handles a request by an actor to change its location. Returns true if the request was
     * dispatched, false if funny business prevented it.
     */
    override public function requestMove (ident :EntityIdent, newloc :OrthLocation) :Boolean
    {
        throttle(ident, _roomObj.orthRoomService.changeLocation, ident, newloc);
        return true;
    }

    /**
     * A callback from the RoomObjectView to let us know that we may want to take a
     * step with door editing.
     */
    public function backgroundFinishedLoading () :void
    {
    }

    /**
     * Handles FURNI_CLICKED.
     */
    override public function handleFurniClicked (furni :FurniData) :void
    {
        if (furni.actionType.isURL()) {
            _orthCtrl.handleViewUrl(furni.splitActionData()[0] as String);

        } else if (furni.actionType.isPortal()) {
            _sceneDir.traversePortal(furni.id);

        } else if (furni.actionType.isHelpPage()) {
            var actionData :Array = furni.splitActionData();
            var tabName :String = String(actionData[0]);
            var url :String = String(actionData[1]);
            // TBD: how to display help pages?

        } else {
            log.warning("Clicked on unhandled furni action type",
               "actionType", furni.actionType, "actionData", furni.actionData);
        }
    }

    override public function getEnvironment () :String
    {
        return "room";
    }

    override public function getMemories (ident :EntityIdent) :Object
    {
        var mems :Object = {};
        var entry :EntityMemories = _roomObj.memories.get(ident) as EntityMemories;
        if (entry != null) {
            entry.memories.forEach(function (key :String, data :ByteArray) :void {
                mems[key] = ObjectMarshaller.decode(data);
            });
        }
        return mems;
    }

    override public function lookupMemory (ident :EntityIdent, key :String) :Object
    {
        var entry :EntityMemories = _roomObj.memories.get(ident) as EntityMemories;
        return (entry == null) ? null
                               : ObjectMarshaller.decode(entry.memories.get(key) as ByteArray);
    }

    override public function canManageRoom (
        memberId :int = 0, allowSupport :Boolean = true) :Boolean
    {
        var me :AetherClientObject = _octx.aetherObject;
        return (memberId == 0 || memberId == me.id) && _scene != null &&
            _scene.canManage(me, allowSupport);
    }

    /**
     * Applies a specified room update object to the current room.
     */
    public function applyUpdate (update :UpdateAction) :void
    {
        _updates.push(update);
    }

    /**
     * Undo the effects of the most recent update. Returns true if the update stack contains more
     * actions, false if it's become empty.
     */
    public function undoLastUpdate () :Boolean
    {
        _updates.pop();
        return _updates.length != 0;
    }

    // documentation inherited
    override public function willEnterPlace (plobj :PlaceObject) :void
    {
        super.willEnterPlace(plobj);

        _roomObj = (plobj as OrthRoomObject);
        _roomObj.addListener(_roomAttrListener);

        // report our location name and owner to interested listeners
        reportLocationName();
        reportLocationOwner();

        // get a copy of the scene
        _scene = _sceneDir.getScene() as OrthScene;

//        _rctx.getChatDirector().registerCommandHandler(
//            Msgs.CHAT, "action", new AvatarChatHandler(false));
//        _rctx.getChatDirector().registerCommandHandler(
//            Msgs.CHAT, "state", new AvatarChatHandler(true));

        _walkTarget.visible = false;
        _flyTarget.visible = false;
        _roomView.appendElement(_flyTarget);
        _roomView.appendElement(_walkTarget);

        _roomView.addEventListener(MouseEvent.CLICK, mouseClicked);
        _roomView.addEventListener(Event.ENTER_FRAME, checkMouse, false, int.MIN_VALUE);
        var stage :Stage = _roomView.stage;
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyEvent);
        stage.addEventListener(KeyboardEvent.KEY_UP, keyEvent);
        _roomView.addEventListener(Event.REMOVED_FROM_STAGE, F.justOnce(function () :void {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyEvent);
            stage.removeEventListener(KeyboardEvent.KEY_UP, keyEvent);
        }));
    }

    // documentation inherited
    override public function didLeavePlace (plobj :PlaceObject) :void
    {
        _updates.reset();

        _rctx.getChatDirector().unregisterCommandHandler(Msgs.CHAT, "action");
        _rctx.getChatDirector().unregisterCommandHandler(Msgs.CHAT, "state");

        _roomView.removeEventListener(MouseEvent.CLICK, mouseClicked);
        _roomView.removeEventListener(Event.ENTER_FRAME, checkMouse);

        _roomView.removeElement(_walkTarget);
        _roomView.removeElement(_flyTarget);
        setHoverSprite(null);

        if (_roomObj != null) {
            _roomObj.removeListener(_roomAttrListener);
            _roomObj = null;
        }

        _scene = null;

        super.didLeavePlace(plobj);
    }

    /**
     * Sends a room update to the server.
     */
    protected function updateRoom (update :SceneUpdate) :void
    {
        _roomObj.orthRoomService.updateRoom(update, Listeners.listener(OrthCodes.EDITING_MSGS));
    }

    override protected function requestAvatarMove (newLoc :OrthLocation) :void
    {
        _spotDir.changeLocation(newLoc, null);
    }

    // documentation inherited
    override protected function setActorState2 (
        ident :EntityIdent, actorOid :int, state :String) :void
    {
        throttle(ident, _roomObj.orthRoomService.setActorState, ident, actorOid, state);
    }

    // documentation inherited
    override protected function sendSpriteMessage2 (
        ident :EntityIdent, name :String, data :ByteArray, isAction :Boolean) :void
    {
        throttle(ident, _roomObj.orthRoomService.sendSpriteMessage, ident, name, data, isAction);
    }

    // documentation inherited
    override protected function sendSpriteSignal2 (
        ident :EntityIdent, name :String, data :ByteArray) :void
    {
        throttle(ident, _roomObj.orthRoomService.sendSpriteSignal, name, data);
    }

    // documentation inherited
    override protected function sendPetChatMessage2 (msg :String, info :ActorInfo) :void
    {
        var svc :PetService = (_rctx.getClient().requireService(PetService) as PetService);
        throttle(info.getEntityIdent(), svc.sendChat,
            info.bodyOid, _scene.getId(), msg, Listeners.confirmListener());
    }

    // documentation inherited
    override protected function updateMemory2 (
        ident :EntityIdent, key :String, data: ByteArray, callback :Function) :void
    {
        var resultHandler :Function = function (success :Boolean) :void {
            if (callback != null) {
                try {
                    callback(success);
                } catch (error :*) {
                    // ignored- error in usercode
                }
            }
        };

        // ship the update request off to the server
        throttle(ident, _roomObj.orthRoomService.updateMemory,
            ident, key, data, Listeners.resultListener(resultHandler));
    }

    /**
     * Find a user's SocializerInfo by their memberId.
     */
    protected function findOccupantById (memberId :int) :SocializerInfo
    {
        for each (var obj :Object in _roomObj.occupantInfo.toArray()) {
            var info :SocializerInfo = obj as SocializerInfo;
            if (info != null && info.id == memberId) {
                return info;
            }
        }
        return null;
    }

    /**
     * Locate an action that matches (case insensitively) the var-args search actions specified.
     */
    protected function locateAction (actions :Array, searches :Array) :String
    {
        searches = searches.map(function (s :String, ... _) :String {
            return s.toLowerCase();
        });
        for each (var action :String in actions) {
            if (action != null && searches.indexOf(action.toLowerCase()) >= 0) {
                return action;
            }
        }
        return null;
    }

    override protected function sceneUpdated (update :SceneUpdate) :void
    {
        super.sceneUpdated(update);

        _roomObjectView.processUpdate(update);
    }

    protected function reportLocationName () :void
    {
        _topPanel.dispatchEvent(new ValueEvent(TopPanel.LOCATION_NAME_CHANGED, _roomObj.name));
    }

    protected function reportLocationOwner () :void
    {
        _topPanel.dispatchEvent(new ValueEvent(TopPanel.LOCATION_OWNER_CHANGED, _roomObj.owner));
    }

    protected function roomAttrChanged (event :AttributeChangedEvent) :void
    {
        if (event.getName() == OrthRoomObject.NAME) {
            reportLocationName();
        } else if (event.getName() == OrthRoomObject.OWNER) {
            reportLocationOwner();
        }
    }

    /** A casted version of _roomView. */
    protected var _roomObjectView :RoomObjectView;

    /** The room object. */
    protected var _roomObj :OrthRoomObject;

    /** The current scene we're viewing. */
    protected var _scene :OrthScene;

    /** Stack that stores the sequence of room updates. */
    protected var _updates :UpdateStack = new UpdateStack(updateRoom);

    /** A flag to indicate that the room editor should be opened when the view is un-minimized */
    protected var _openEditor :Boolean = false;

    /** Listens for room attribute changes. */
    protected var _roomAttrListener :AttributeChangeAdapter =
        new AttributeChangeAdapter(roomAttrChanged);

    protected const _module :Module = inject(Module);
}
}
