//
// $Id: RoomObjectController.as 19189 2010-05-26 19:37:09Z zell $

package com.threerings.orth.room.client {
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.ByteArray;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;
import com.threerings.flex.CommandMenu;
import com.threerings.whirled.data.SceneUpdate;

import com.threerings.util.ArrayUtil;
import com.threerings.util.ObjectMarshaller;
import com.threerings.util.ValueEvent;

import com.threerings.presents.dobj.AttributeChangeAdapter;
import com.threerings.presents.dobj.AttributeChangedEvent;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.MediaDescSize;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.entity.client.ActorSprite;
import com.threerings.orth.entity.client.MemberSprite;
import com.threerings.orth.entity.client.PetSprite;
import com.threerings.orth.entity.data.Avatar;
import com.threerings.orth.entity.data.PetOrders;
import com.threerings.orth.room.client.updates.UpdateAction;
import com.threerings.orth.room.client.updates.UpdateStack;
import com.threerings.orth.room.data.ActorInfo;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityMemories;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthRoomObject;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.PetInfo;
import com.threerings.orth.room.data.PetName;
import com.threerings.orth.room.data.SocializerInfo;
import com.threerings.orth.room.data.SocializerObject;
import com.threerings.orth.ui.MediaWrapper;
import com.threerings.orth.world.client.BootablePlaceController;

/**
 * Manages the various interactions that take place in a room scene.
 */
public class RoomObjectController extends RoomController
    implements BootablePlaceController
{
    /** Some commands */
    public static const EDIT_DOOR :String = "EditDoor";
    public static const PUBLISH_ROOM :String = "PublishRoom";
    public static const SEND_POSTCARD :String = "SendPostcard";

    // documentation inherited
    override protected function createPlaceView (ctx :CrowdContext) :PlaceView
    {
        _roomObjectView = new RoomObjectView(_rctx, this);
        _roomView = _roomObjectView;
        return _roomObjectView;
    }

    // from interface BootablePlaceController
    public function canBoot () :Boolean
    {
        return canManageRoom();
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
     * Add to the specified menu, any room/avatar related menu items.
     */
    public function addAvatarMenuItems (name :PlayerName, menuItems :Array) :void
    {
        const occInfo :SocializerInfo = _roomObj.getOccupantInfo(name) as SocializerInfo;
        if (occInfo == null) {
            return;
        }

        const us :SocializerObject = _rctx.getSocializerObject();
        const avatar :MemberSprite = _roomObjectView.getOccupant(occInfo.bodyOid) as MemberSprite;
        // avatar may be null if not yet loaded. We check below..

        // then add our custom menu items
        if (occInfo.bodyOid == us.getOid()) {
            // if we're not a guest add a menu for changing avatars
            menuItems.push(createChangeAvatarMenu(us, true));
            // add our custom menu items (avatar actions and states)
            if (avatar != null) {
                addSelfMenuItems(avatar, menuItems, true);
            }
        }
    }

    /**
     * Set the specified name hovered or unhovered.
     */
    public function setHoverName (name :OrthName, hovered :Boolean) :void
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
     * Returns true if we are in edit mode, false if not.
     */
    public function isRoomEditing () :Boolean
    {
        // ORTH TODO
        // return (_editor != null) && _editor.isEditing();
        return false;
    }

    /**
     * Handles EDIT_DOOR.
     */
    public function handleEditDoor (furniData :FurniData) :void
    {
        if (isRoomEditing()) {
            cancelRoomEditing();
        }

        // ORTH TODO
        // var handleResult :Function = function (result :Object) :void {
        //     DoorTargetEditController.start(furniData, _rctx);
        // };
        // _roomObj.orthRoomService.editRoom(_octx.resultListener(handleResult, OrthCodes.EDITING_MSGS));
    }

    /**
     * A callback from the RoomObjectView to let us know that we may want to take a
     * step with door editing.
     */
    public function backgroundFinishedLoading () :void
    {
        // ORTH TODO
//        DoorTargetEditController.updateLocation();
    }

    /**
     * Handle the ROOM_EDIT command.
     */
    public function handleRoomEdit () :void
    {
        if (!canManageRoom()) {
            return;
        }

        // TODO: debounce the button, since we're round-trippin' to the server..
        if (isRoomEditing()) {
            cancelRoomEditing();
            return;
        }

        var handleResult :Function = function (result :Object) :void {
            beginRoomEditing();
        };
        // ORTH TODO
//        _roomObj.orthRoomService.editRoom(_octx.resultListener(handleResult, OrthCodes.EDITING_MSGS));
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

    /**
     * Handles AVATAR_CLICKED.
     */
    override public function handleAvatarClicked (avatar :MemberSprite) :void
    {
        var occInfo :SocializerInfo = (avatar.getActorInfo() as SocializerInfo);
        if (occInfo == null) {
            log.info("Clicked on non-SocializerInfo sprite", "info", avatar.getActorInfo());
            return;
        }

        var menuItems :Array = [];
        _worldCtrl.addMemberMenuItems(occInfo.username as PlayerName, menuItems);
        popActorMenu(avatar, menuItems);
    }

    /**
     * Create the menu item that allows a user to change their own avatar.
     */
    protected function createChangeAvatarMenu (us :SocializerObject, canControl :Boolean) :Object
    {
        var avItems :Array = [];
        var avatars :Array = (us.avatarCache != null) ? us.avatarCache.toArray() : [];
        ArrayUtil.sort(avatars);

        for (var ii :int = 0; ii < avatars.length; ii++) {
            var av :Avatar = avatars[ii] as Avatar;
            avItems.push({ label: av.name, enabled: !av.equals(us.avatar),
                iconObject: MediaWrapper.createView(
                    av.getThumbnailMedia(), MediaDescSize.QUARTER_THUMBNAIL_SIZE),
                callback: _playerDir.setAvatar, arg: av.getIdent().getItem() });
        }

        // return a menu item for changing their avatar
        return { label: Msgs.GENERAL.get("b.change_avatar"), children: avItems,
            enabled: canControl };
    }

    /**
     * Handles PET_CLICKED.
     */
    override public function handlePetClicked (pet :ActorSprite) :void
    {
        var occInfo :PetInfo = (pet.getActorInfo() as PetInfo);
        if (occInfo == null) {
            log.warning("Pet has unexpected ActorInfo", "info", pet.getActorInfo());
            return;
        }

        const memObj :SocializerObject = _rctx.getSocializerObject();
        const isPetOwner :Boolean = (PetSprite(pet).getOwnerId() == memObj.getPlayerId());
        const petId :int = occInfo.getEntityIdent().getItem();

        var menuItems :Array = [];

        _worldCtrl.addPetMenuItems(PetName(occInfo.username), menuItems);

        if (isPetOwner) {
            CommandMenu.addSeparator(menuItems);
            var isWalking :Boolean = (memObj.walkingId != 0);
            menuItems.push(
            { label: Msgs.GENERAL.get("b.order_pet_stay"),
              command: ORDER_PET, arg: [ petId, PetOrders.ORDER_STAY ], enabled: canManageRoom() },
            { label: Msgs.GENERAL.get("b.order_pet_follow"),
              command: ORDER_PET, arg: [ petId, PetOrders.ORDER_FOLLOW ], enabled: !isWalking },
            { label: Msgs.GENERAL.get("b.order_pet_go_home"),
              command: ORDER_PET, arg: [ petId, PetOrders.ORDER_GO_HOME ] });
        }
        if (isPetOwner || canManageRoom()) {
            CommandMenu.addSeparator(menuItems);
            // and any old room manager can put the pet to sleep
            menuItems.push({ label: Msgs.GENERAL.get("b.order_pet_sleep"),
                command: ORDER_PET, arg: [ petId, PetOrders.ORDER_SLEEP ] });
        }

        popActorMenu(pet, menuItems);
    }

    /**
     * Handles ORDER_PET.
     */
    override public function handleOrderPet (petId :int, command :int) :void
    {
        var svc :PetService = (_rctx.getClient().requireService(PetService) as PetService);
        svc.orderPet(petId, command, _octx.confirmListener("m.pet_ordered" + command));
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
        var me :PlayerObject = _octx.getPlayerObject();
        if (memberId == 0 || (memberId == me.getPlayerId())) { // self
            return (_scene != null && _scene.canManage(me, allowSupport));

        } else { // others
            return false;
        }
    }

    /**
     * End editing the room.
     */
    public function cancelRoomEditing () :void
    {
        // ORTH TODO
//        _editor.endEditing();
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
        _roomView.addChildAt(_flyTarget, _roomView.numChildren);
        _roomView.addChildAt(_walkTarget, _roomView.numChildren);

        _roomView.addEventListener(MouseEvent.CLICK, mouseClicked);
        _roomView.addEventListener(Event.ENTER_FRAME, checkMouse, false, int.MIN_VALUE);
        _roomView.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyEvent);
        _roomView.stage.addEventListener(KeyboardEvent.KEY_UP, keyEvent);
    }

    // documentation inherited
    override public function didLeavePlace (plobj :PlaceObject) :void
    {
        _updates.reset();
        if (isRoomEditing()) {
            cancelRoomEditing();
        }

        _rctx.getChatDirector().unregisterCommandHandler(Msgs.CHAT, "action");
        _rctx.getChatDirector().unregisterCommandHandler(Msgs.CHAT, "state");

        _roomView.removeEventListener(MouseEvent.CLICK, mouseClicked);
        _roomView.removeEventListener(Event.ENTER_FRAME, checkMouse);
        _roomView.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyEvent);
        _roomView.stage.removeEventListener(KeyboardEvent.KEY_UP, keyEvent);

        _roomView.removeChild(_walkTarget);
        _roomView.removeChild(_flyTarget);
        setHoverSprite(null);

        if (_roomObj != null) {
            _roomObj.removeListener(_roomAttrListener);
            _roomObj = null;
        }

        _scene = null;

        super.didLeavePlace(plobj);
    }

    /**
     * Begins editing the room.
     */
    protected function beginRoomEditing () :void
    {
        _walkTarget.visible = false;
        _flyTarget.visible = false;

        // this function will be called when the edit panel is closing
        // ORTH TODO
        // var wrapupFn :Function = function () :void {
        //     _editor = null;
        // }

        // _editor = new RoomEditorController(_rctx, _roomObjectView);
        // _editor.startEditing(wrapupFn);
        // _editor.updateUndoStatus(_updates.length != 0);
    }

    /**
     * Sends a room update to the server.
     */
    protected function updateRoom (update :SceneUpdate) :void
    {
        // ORTH TODO
//        _roomObj.orthRoomService.updateRoom(update, _octx.listener(OrthCodes.EDITING_MSGS));
    }

    override protected function checkMouse2 (
        grabAll :Boolean, allowMovement :Boolean, setHitter :Function) :void
    {
        grabAll = isRoomEditing();
        if (grabAll) {
        // ORTH TODO
            // allowMovement = _editor.isMovementEnabled();
            // setHitter = _editor.mouseOverSprite;
        }

        super.checkMouse2(grabAll, allowMovement, setHitter);
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
            info.bodyOid, _scene.getId(), msg, _octx.confirmListener());
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
            ident, key, data, _octx.resultListener(resultHandler));
    }

    // documentation inherited
    override protected function keyEvent (event :KeyboardEvent) :void
    {
        if (event.keyCode == Keyboard.F6) {
            _comicOverlay.setClickableGlyphs(event.type == KeyboardEvent.KEY_DOWN);
            event.updateAfterEvent();
            return;
        }

        super.keyEvent(event);
    }

    /**
     * Find a user's SocializerInfo by their memberId.
     */
    protected function findOccupantById (memberId :int) :SocializerInfo
    {
        for each (var obj :Object in _roomObj.occupantInfo.toArray()) {
            var info :SocializerInfo = obj as SocializerInfo;
            if (info != null && info.getPlayerId() == memberId) {
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
        // ORTH TODO
        // if (_editor != null) {
        //     _editor.processUpdate(update);
        // }
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

    /** Controller for in-room furni editing. */
    // ORTH TODO
//    protected var _editor :RoomEditorController;

    /** Stack that stores the sequence of room updates. */
    protected var _updates :UpdateStack = new UpdateStack(updateRoom);

    /** A flag to indicate that the room editor should be opened when the view is un-minimized */
    protected var _openEditor :Boolean = false;

    /** Listens for room attribute changes. */
    protected var _roomAttrListener :AttributeChangeAdapter =
        new AttributeChangeAdapter(roomAttrChanged);

}
}
