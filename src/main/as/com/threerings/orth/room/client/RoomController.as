//
// $Id: RoomController.as 17898 2009-08-24 03:38:13Z ray $

package com.threerings.orth.room.client {

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.getTimer;

import flashx.funk.ioc.inject;

import mx.controls.Button;
import mx.controls.Menu;
import mx.events.MenuEvent;

import com.threerings.crowd.chat.client.MuteDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceConfig;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;
import com.threerings.flex.CommandButton;
import com.threerings.flex.CommandMenu;
import com.threerings.whirled.client.SceneController;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.spot.client.SpotSceneDirector;

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.ObjectMarshaller;

import com.threerings.orth.aether.client.AetherDirector;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.client.ControlBar;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.OrthController;
import com.threerings.orth.client.OrthPlaceBox;
import com.threerings.orth.client.OrthResourceFactory;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.data.MediaDescSize;
import com.threerings.orth.entity.client.ActorSprite;
import com.threerings.orth.entity.client.EntitySprite;
import com.threerings.orth.entity.client.MemberSprite;
import com.threerings.orth.locus.client.BootablePlaceController;
import com.threerings.orth.locus.client.LocusController;
import com.threerings.orth.locus.client.LocusDirector;
import com.threerings.orth.room.data.ActorInfo;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityMemories;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.PetName;
import com.threerings.orth.room.data.SimpleEntityIdent;
import com.threerings.orth.ui.MediaWrapper;

/**
 * Manages the various interactions that take place in a room scene.
 */
public class RoomController extends SceneController
{
    /** Logging facilities. */
    protected static const log :Log = Log.getLog(RoomController);

    /** Command to display a simplified menu for muting/etc a member. */
    public static const POP_MEMBER_MENU :String = "PopMemberMenu";

    /** Command to display a simplified menu for muting/etc a pet. */
    // nada here. Pets only exist in world, but we handle them generically
    public static const POP_PET_MENU :String = "PopPetMenu";

    /** Command to view a member's profile, arg is [ memberId ] */
    public static const VIEW_MEMBER :String = "ViewMember";

    /** Command to display the chat channel menu. */
    public static const POP_CHANNEL_MENU :String = "PopChannelMenu";

    /** Command to display the room menu. */
    public static const POP_ROOM_MENU :String = "PopRoomMenu";

    /** Command to go to a particular place (by Oid). */
    public static const GO_LOCATION :String = "GoLocation";

    /** Command to go to a particular scene. */
    public static const GO_SCENE :String = "GoScene";

    /** Some commands. */
    public static const FURNI_CLICKED :String = "FurniClicked";
    public static const AVATAR_CLICKED :String = "AvatarClicked";
    public static const PET_CLICKED :String = "PetClicked";

    public static const ORDER_PET :String = "OrderPet";

    /** Opens up a new toolbar and a new room editor. */
    public static const ROOM_EDIT :String = "RoomEdit";

    public static const MAX_ENCODED_MESSAGE_LENGTH :int = 1024;

    // documentation inherited
    override public function init (ctx :CrowdContext, config :PlaceConfig) :void
    {
        super.init(ctx, config);

        _throttleChecker.addEventListener(TimerEvent.TIMER, handleCheckThrottles);
    }

    // documentation inherited
    override public function willEnterPlace (plobj :PlaceObject) :void
    {
        super.willEnterPlace(plobj);

        _throttleChecker.start();
    }

    // documentation inherited
    override public function didLeavePlace (plobj :PlaceObject) :void
    {
        super.didLeavePlace(plobj);

        _throttleChecker.stop();
        // see if this is causing the drop of any messages
        for each (var throttler :Throttler in _throttlers.values()) {
            throttler.noteDrop();
        }
        _throttlers.clear();
    }

    // documentation inherited
    override protected function createPlaceView (ctx :CrowdContext) :PlaceView
    {
        _roomView = new RoomView(_rctx, this);
        return _roomView;
    }

    /**
     * Get the instanceId of all the entity instances in the room.  This is used so that two
     * instances of a pet can negotiate which client will control it, for example.
     */
    public function getEntityInstanceId () :int
    {
        var name :PlayerName = _rctx.getMyName();
        return (name != null) ? name.getId() : 0;
    }

    /**
     * Get the display name of the user viewing a particular instance.
     */
    public function getViewerName (instanceId :int = 0) :String
    {
        var name :PlayerName = _rctx.getMyName();
        if (instanceId == 0 || instanceId == name.getId()) {
            return name.toString();
        }
        return null;
        // see subclasses for more...
    }

    /**
     * Return the environment in which the entities are running.
     */
    public function getEnvironment () :String
    {
        return "viewer"; // ENV_VIEWER. See subclasses.
    }

    /**
     * Return true if we're in a place in which memories will save.
     */
    public function memoriesWillSave () :Boolean
    {
        return true;
    }

    /**
     * Get the specified item's room memories in a map.
     */
    public function getMemories (ident :EntityIdent) :Object
    {
        return {}; // see subclasses
    }

    /**
     * Look up a particular memory key for the specified item.
     */
    public function lookupMemory (ident :EntityIdent, key :String) :Object
    {
        return null; // see subclasses
    }

    /**
     * Does this user have management permission in this room?
     */
    public function canManageRoom (memberId :int = 0, allowSupport :Boolean = true) :Boolean
    {
        return false;
    }

    /**
     * Requests that an item be removed from the owner's inventory.
     */
    public function deleteItem (ident :EntityIdent) :void
    {
        // see subclasses
    }

    /**
     * Requests to rate this room.
     */
    public function rateRoom (rating :Number, onSuccess :Function) :void
    {
        // see subclasses
    }

    /**
     * Handles a request by an item in our room to send an "action" or a "message".
     */
    public function sendSpriteMessage (
        ident :EntityIdent, name :String, arg :Object, isAction :Boolean) :void
    {
        // send the request off to the server
        var data :ByteArray = ObjectMarshaller.validateAndEncode(arg, MAX_ENCODED_MESSAGE_LENGTH);
        sendSpriteMessage2(ident, name, data, isAction);
    }

    /**
     * Handles a request by an item in our room to send a "signal" to all the instances of
     * all the entities in the room.
     */
    public function sendSpriteSignal (ident :EntityIdent, name :String, arg :Object) :void
    {
        var data :ByteArray = ObjectMarshaller.validateAndEncode(arg, MAX_ENCODED_MESSAGE_LENGTH);
        sendSpriteSignal2(ident, name, data);
    }

    /**
     * Handles a request by an actor item to change its persistent state.
     */
    public function setActorState (ident :EntityIdent, actorOid :int, state :String) :void
    {
        setActorState2(ident, actorOid, state);
    }

    /**
     * Handles a request by an entity item to send a chat message.
     */
    public function sendPetChatMessage (msg :String, info :ActorInfo) :void
    {
        sendPetChatMessage2(msg, info);
    }

    /**
     * Handles a request by an item in our room to update its memory.
     */
    public function updateMemory (
        ident :EntityIdent, key :String, value: Object, callback :Function) :void
    {
//        validateKey(key);
        // This will validate that the memory being set isn't greater than the maximum
        // alloted space for all memories, becauses that will surely fail on the server,
        // but the server will do further checks to ensure that this entry can be
        // safely added to the memory set such that combined they're all under the maximum.
        var data :ByteArray = ObjectMarshaller.validateAndEncode(value,
                EntityMemories.MAX_ENCODED_MEMORY_LENGTH);
        updateMemory2(ident, key, data, callback);
    }

    /**
     * Retrieves a published property of a given entity.
     */
    public function getEntityProperty (ident :EntityIdent, key :String) :Object
    {
        var sprite :EntitySprite = _roomView.getEntity(ident);

        return (sprite == null) ? null : sprite.lookupEntityProperty(key);
    }

    /**
     * Get the ID strings of all entities of the specified type, or all if type is null.
     * @see ENTITY_TYPES
     */
    public function getEntityIds (type :String = null) :Array
    {
        var idents :Array = _roomView.getEntityIdents();

        // Filter for items of the correct type, if necessary
        if (type != null) {
            idents = idents.filter(
                function (id :EntityIdent, ... etc) :Boolean {
                    // Is the entity a valid item of this type?
                    return id.getType().getPropertyType() == type;
                });
        }

        // Convert from EntityIdents to entityId Strings
        return idents.map(
            function (id :EntityIdent, ... etc) :String {
                return SimpleEntityIdent.toString(id);
            });
    }

    /**
     * Handles a request by an actor to change its location. Returns true if the request was
     * dispatched, false if funny business prevented it.
     */
    public function requestMove (ident :EntityIdent, newloc :OrthLocation) :Boolean
    {
        // handled in subclasses
        return false;
    }

    /**
     * Called to enact the avatar action globally: all users will see it.
     */
    public function doAvatarAction (action :String) :void
    {
        sendSpriteMessage(_roomView.getMyAvatar().getEntityIdent(), action, null, true);
    }

    /**
     * Called to enact an avatar state change.
     */
    public function doAvatarState (state :String) :void
    {
        var avatar :MemberSprite = _roomView.getMyAvatar();
        setActorState(avatar.getEntityIdent(), avatar.getOid(), state);
    }

    /**
     * Handles FURNI_CLICKED.
     */
    public function handleFurniClicked (furni :FurniData) :void
    {
        // see subclasses
    }

    /**
     * Add menu items for triggering actions and changing state on our avatar.
     */
    protected function addSelfMenuItems (
        avatar :MemberSprite, menuItems :Array, canControl :Boolean) :void
    {
        CommandMenu.addSeparator(menuItems);

        // create a sub-menu for playing avatar actions
        var actions :Array = avatar.getAvatarActions();
        if (actions.length > 0) {
            var worldActions :Array = [];
            for each (var act :String in actions) {
                worldActions.push({ label: act, callback: doAvatarAction, arg: act });
            }
            menuItems.push({ label: Msgs.GENERAL.get("l.avAction"),
                children: worldActions, enabled: canControl });
        }

        // create a sub-menu for changing avatar states
        var states :Array = avatar.getAvatarStates();
        if (states.length > 0) {
            var worldStates :Array = [];
            var curState :String = avatar.getState();
            // NOTE: we usually want to translate null into the first state, however, if there's
            // only one state registered, let them select it anyway by not translating.
            if (states.length > 1 && curState == null) {
                curState = states[0];
            }
            for each (var state :String in states) {
                worldStates.push({ label: state, callback: doAvatarState, arg :state,
                    enabled: (curState != state) });
            }
            menuItems.push({ label: Msgs.GENERAL.get("l.avStates"),
                children: worldStates, enabled: canControl });
        }
    }

    /**
     * Pop up an actor menu.
     */
    protected function popActorMenu (sprite :ActorSprite, menuItems :Array) :void
    {
        // pop up the menu where the mouse is
        if (menuItems.length > 0) {
            var menu :CommandMenu = CommandMenu.createMenu(menuItems, _roomView);
            menu.setBounds(_topPanel.getMainAreaBounds());
            menu.popUpAtMouse();
            menu.addEventListener(MenuEvent.MENU_HIDE, function (event :MenuEvent) :void {
                if (event.menu == menu) {
                    _clickSuppress = sprite;
                    _topPanel.addEventListener(
                        MouseEvent.MOUSE_DOWN, clearClickSuppress, false, 0, true);
                }
            });

//            var menu :RadialMenu = new RadialMenu();
//            menu.dataProvider = menuItems;
        }
    }

    /**
     * Handles AVATAR_CLICKED.
     */
    public function handleAvatarClicked (avatar :MemberSprite) :void
    {
        // nada here, see subclasses
    }

    /**
     * Handles PET_CLICKED.
     */
    public function handlePetClicked (pet :ActorSprite) :void
    {
        // see subclasses
    }

    /**
     * Handles ORDER_PET.
     */
    public function handleOrderPet (petId :int, command :int) :void
    {
        // see subclasses / TODO
    }

    /**
     * Get the top-most sprite mouse-capturing sprite with a non-transparent pixel at the specified
     * location.
     *
     * @return undefined if the mouse isn't in our bounds, or null, or an EntitySprite.
     */
    public function getHitSprite (stageX :Number, stageY :Number, all :Boolean = false) :*
    {
        // check to make sure we're within the bounds of the place container
        var container :OrthPlaceBox = _topPanel.getPlaceContainer();
        var containerP :Point = container.localToGlobal(new Point());
        if (stageX < containerP.x || stageX > containerP.x + container.width ||
            stageY < containerP.y || stageY > containerP.y + container.height) {
            return undefined;
        }

        // ORTH TODO: we will handle popups/windows some other way
        // first, avoid any popups
        // var smgr :ISystemManager = _app.systemManager;
        // var ii :int;
        // var disp :DisplayObject;
        // for (ii = smgr.numChildren - 1; ii >= 0; ii--) {
        //     disp = smgr.getChildAt(ii)
        //     if ((disp is Application) || (disp is UIComponent && !UIComponent(disp).visible)) {
        //         continue;
        //     }
        //     if (disp.hitTestPoint(stageX, stageY)) {
        //         return undefined;
        //     }
        // }

        // then check with the OrthPlaceBox
        if (container.overlaysMousePoint(stageX, stageY)) {
            return undefined;
        }

        // we search from last-drawn to first drawn to get the topmost...
        for (var dex :int = _roomView.numChildren - 1; dex >= 0; dex--) {
            // see if this child represents a RoomElement
            var el :RoomElement = _roomView.vizToEntity(_roomView.getChildAt(dex));
            // and we're actually only interested in EntitySprite objects
            var spr :EntitySprite = (el as EntitySprite);

            if ((spr != null) && (all || (spr.isActive() && spr.capturesMouse())) &&
                spr.viz.hitTestPoint(stageX, stageY, true))
            {
                return spr;
            }
        }

        return null;
    }

    /**
     * Handles ENTER_FRAME and see if the mouse is now over anything.  Normally the flash player
     * will dispatch mouseOver/mouseLeft for an object even if the mouse isn't moving: the sprite
     * could move.  Since we're hacking in our own mouseOver handling, we emulate that.  Gah.
     */
    protected function checkMouse (event :Event) :void
    {
        // skip if supressed, and freak not out if we're temporarily removed from the stage
        if (_suppressNormalHovering || _roomView.stage == null) {
            return;
        }

//        // in case a mouse event was captured by an entity, prevent it from adding a popup later
//        _entityAllowedToPop = null;
        checkMouse2(false, false, null);
    }

    /**
     * Helper for checkMouse. Broken out for subclasses to override.
     *
     * @param grabAll if true, grab all sprites
     * @param allowMovement only consulted when grabAll is true.
     * @param setHitter only used when grabAll is true.
     */
    protected function checkMouse2 (
        grabAll :Boolean, allowMovement :Boolean, setHitter :Function) :void
    {
        var sx :Number = _roomView.stage.mouseX;
        var sy :Number = _roomView.stage.mouseY;
        var showWalkTarget :Boolean = false;
        var showFlyTarget :Boolean = false;
        var hoverTarget :EntitySprite = null;

        // if shift is being held down, we're looking for locations only, so
        // skip looking for hitSprites.
        var hit :* = (_shiftDownSpot == null) ? getHitSprite(sx, sy, grabAll) : null;
        var hitter :EntitySprite = (hit as EntitySprite);
        // ensure we hit no pop-ups
        if (hit !== undefined) {
            hoverTarget = hitter;
            if (hitter == null) {
                var cloc :ClickLocation = _roomView.layout.pointToAvatarLocation(
                    sx, sy, _shiftDownSpot, RoomMetrics.N_UP);

                if (cloc != null) {
                    addAvatarYOffset(cloc);
                    if (cloc.loc.y != 0) {
                        _flyTarget.setLocation(cloc.loc);
                        _roomView.layout.updateScreenLocation(_flyTarget);
                        showFlyTarget = true;

                        // Set the Y to 0 and use it for the walkTarget
                        cloc.loc.y = 0;
                        _walkTarget.alpha = .5;

                    } else {
                        _walkTarget.alpha = 1;
                    }

                    var walkable :Boolean = _roomView.canWalkTo(cloc.loc);

                    // don't show the walk target if we're "in front" of the room view
                    showWalkTarget = (walkable && cloc.loc.z >= 0);
                    _walkTarget.setLocation(cloc.loc);
                    _roomView.layout.updateScreenLocation(_walkTarget);
                }

            } else if (!hoverTarget.hasAction()) {
                // it may have captured the mouse, but it doesn't actually
                // have any action, so we don't hover it.
                hoverTarget = null;
            }

            // if we're in grab-all mode, we operate slightly differently: don't actually highlight
            if (grabAll) {
                hoverTarget = null;

                // possibly hide walk targets too
                showWalkTarget = (showWalkTarget && allowMovement);
                showFlyTarget = (showFlyTarget && allowMovement);

                // indicate which sprite is being hovered
                setHitter(hitter);
            }
        }

        _walkTarget.visible = showWalkTarget;
        _flyTarget.visible = showFlyTarget;

        setHoverSprite(hoverTarget, sx, sy);
    }

    /**
     * Set the special singleton sprite that the mouse is hovering over.
     */
    protected function setHoverSprite (
        sprite :EntitySprite, stageX :Number = NaN, stageY :Number = NaN) :void
    {
        // iff the sprite has changed..
        if (_hoverSprite != sprite) {
            // unglow the old sprite (and remove any tooltip)
            if (_hoverSprite != null) {
                setSpriteHovered(_hoverSprite, false, stageX, stageY);
            }

            // assign the new hoversprite, maybe assigning to null
            _hoverSprite = sprite;
        }

        // glow the sprite (and give it a chance update the tip)
        if (_hoverSprite != null) {
            setSpriteHovered(_hoverSprite, true, stageX, stageY);
        }
    }

    /**
     * This sets the particular sprite to be hovered or no. This can be called even for
     * sprites other than the _hoverSprite.
     */
    public function setSpriteHovered (
        sprite :EntitySprite, hovered: Boolean, stageX :Number = NaN, stageY :Number = NaN) :void
    {
        // update the glow on the sprite
        var text :Object = sprite.setHovered(hovered, stageX, stageY);
        if (hovered && text === true) {
            return; // this is a special-case shortcut we use to save time.
        }
        // ORTH TODO: if we do tooltips, it'll be done in a non flex way
        // var tip :IToolTip = IToolTip(_hoverTips[sprite]);
        // // maybe remove the tip
        // if ((tip != null) && (!hovered || text == null || tip.text != text)) {
        //     delete _hoverTips[sprite];
        //     ToolTipManager.destroyToolTip(tip);
        //     tip = null;
        // }
        // // maybe add a new tip
        // if (hovered && (text != null)) {
        //     if (isNaN(stageX) || isNaN(stageY)) {
        //         var p :Point = sprite.viz.localToGlobal(sprite.getLayoutHotSpot());
        //         stageX = p.x;
        //         stageY = p.y;
        //     }
        //     _hoverTips[sprite] = addHoverTip(
        //         sprite, String(text), stageX, stageY + MOUSE_TOOLTIP_Y_OFFSET);
        // }
    }

    /**
     * Utility method to create and style the hover tip for a sprite.
     */
        // ORTH TODO: if we do tooltips, it'll be done in a non flex way
    // protected function addHoverTip (
    //     sprite :EntitySprite, tipText :String, stageX :Number, stageY :Number) :IToolTip
    // {
    //     var tip :IToolTip = ToolTipManager.createToolTip(tipText, stageX, stageY);
    //     var tipComp :UIComponent = UIComponent(tip);
    //     tipComp.styleName = "roomToolTip";
    //     tipComp.x -= tipComp.width/2;
    //     tipComp.y -= tipComp.height/2;
    //     PopUpUtil.fitInRect(tipComp, _topPanel.getPlaceViewBounds());
    //     var hoverColor :uint = sprite.getHoverColor();
    //     tipComp.setStyle("color", hoverColor);
    //     if (hoverColor == 0) {
    //         tipComp.setStyle("backgroundColor", 0xFFFFFF);
    //     }
    //     return tip;
    // }

    protected function mouseClicked (event :MouseEvent) :void
    {
        if (_suppressNormalHovering) {
            return;
        }

//        // at this point, the mouse click is bubbling back out, and the entity is no
//        // longer allowed to pop up a popup.
//        _entityAllowedToPop = null;

        // if shift is being held down, we're looking for locations only, so skip looking for
        // hitSprites.
        var hit :* = (_shiftDownSpot == null) ? getHitSprite(event.stageX, event.stageY) : null;
        if (hit === undefined) {
            return;
        }

        // deal with the target
        var hitter :EntitySprite = (hit as EntitySprite);
        if (hitter != null) {
            // let the sprite decide what to do with it
            if (hitter != _clickSuppress) {
                hitter.mouseClick(event);
            }

        } else {
            var curLoc :OrthLocation = _roomView.getMyCurrentLocation();
            if (curLoc == null) {
                return; // we've already left, ignore the click
            }

            // calculate where the location is
            var cloc :ClickLocation = _roomView.layout.pointToAvatarLocation(
                event.stageX, event.stageY, _shiftDownSpot, RoomMetrics.N_UP);
            // disallow clicking in "front" of the scene when minimized
            if (cloc != null && cloc.loc.z >= 0) {
                // orient the location as appropriate
                addAvatarYOffset(cloc);
                var newLoc :OrthLocation = cloc.loc;
                var degrees :Number = 180 / Math.PI *
                    Math.atan2(newLoc.z - curLoc.z, newLoc.x - curLoc.x);
                // we rotate so that 0 faces forward
                newLoc.orient = (degrees + 90 + 360) % 360;
                // effect the move
                requestAvatarMove(newLoc);
            }
        }
    }

    /**
     * Clear out the click suppress sprite.
     */
    protected function clearClickSuppress (event :MouseEvent) :void
    {
        _clickSuppress = null;
        _topPanel.removeEventListener(MouseEvent.MOUSE_DOWN, clearClickSuppress);
    }

    /**
     * Effect a move for our avatar.
     */
    protected function requestAvatarMove (newLoc :OrthLocation) :void
    {
        // nada here, see subclasses
    }

    /**
     * Once the state change has been validated, effect it.
     */
    protected function setActorState2 (ident :EntityIdent, actorOid :int, state :String) :void
    {
        // see subclasses
    }

    /**
     * Once a sprite message is validated and ready to go, it is sent here.
     */
    protected function sendSpriteMessage2 (
        ident :EntityIdent, name :String, data :ByteArray, isAction :Boolean) :void
    {
        // see subclasses
    }

    /**
     * Once a sprite signal is validated and ready to go, it is sent here.
     */
    protected function sendSpriteSignal2 (ident :EntityIdent, name :String, data :ByteArray) :void
    {
        // see subclasses
    }

    /**
     * Once a pet chat is validated and ready to go, it is sent here.
     */
    protected function sendPetChatMessage2 (msg :String, info :ActorInfo) :void
    {
        // see subclasses
    }

    /**
     * Once a memory update is validated and ready to go, it is sent here.
     */
    protected function updateMemory2 (
        ident :EntityIdent, key :String, data :ByteArray, callback :Function) :void
    {
        // see subclasses
    }

    protected function keyEvent (event :KeyboardEvent) :void
    {
        try {
            var keyDown :Boolean = event.type == KeyboardEvent.KEY_DOWN;
            switch (event.keyCode) {
            case Keyboard.F4:
                _roomView.dimAvatars(keyDown);
                return;

            case Keyboard.F5:
                _roomView.dimFurni(keyDown);
                return;

            case Keyboard.SHIFT:
                _shiftDown = keyDown;
                if (keyDown) {
                    if (_walkTarget.visible && (_shiftDownSpot == null)) {
                        // record the y position at this
                        _shiftDownSpot = new Point(_roomView.stage.mouseX, _roomView.stage.mouseY);
                    }

                } else {
                    _shiftDownSpot = null;
                }
                return;
            }

        } finally {
            event.updateAfterEvent();
        }
    }

    /**
     * Return the avatar's preferred y offset for normal mouse positioning,
     * unless shift is being held down, in which case use 0 so that the user
     * can select their height precisely.
     */
    protected function addAvatarYOffset (cloc :ClickLocation) :void
    {
        if (_shiftDownSpot != null) {
            return;
        }

        var av :MemberSprite = _roomView.getMyAvatar();
        if (av != null) {
            var prefY :Number = av.getPreferredY() / _roomView.layout.metrics.sceneHeight;
            // but clamp their preferred Y into the normal range
            cloc.loc.y = Math.min(1, Math.max(0, prefY));
        }
    }

//    protected function validateKey (key :String) :void
//    {
//        if (key == null) {
//            throw new Error("Null is an invalid key!");
//        }
//        for (var ii :int = 0; ii < key.length; ii++) {
//            if (key.charAt(ii) > "\u007F") {
//                throw new Error("Unicode characters not supported in keys.");
//            }
//        }
//    }

    protected function throttle (ident :EntityIdent, fn :Function, ... args) :void
    {
        var av :EntitySprite = _roomView.getMyAvatar();
        if (av != null && av.getEntityIdent().equals(ident)) {
            // our own avatar is never throttled
            fn.apply(null, args);

        } else {
            // else, subject to throttling
            var throttler :Throttler = _throttlers.get(ident) as Throttler;
            if (throttler == null) {
                throttler = new Throttler(ident);
                _throttlers.put(ident, throttler);
            }
            throttler.processOp(fn, args);
        }
    }

    /**
     * Check queued messages to see if there are any we should send now.
     */
    protected function handleCheckThrottles (... ignored) :void
    {
        var now :int = getTimer();
        for each (var throttler :Throttler in _throttlers.values()) {
            // make sure it's a valid entity still
            // (We do this here instead of at the time the sprite is removed because sometimes
            // things are removed and re-added when simply repositioned. This lets that settle..).
            if (null == _roomView.getEntity(throttler.ident)) {
                throttler.noteDrop();
                _throttlers.remove(throttler.ident);

            } else {
                // it's in the room, it's cool
                throttler.checkOps(now);
            }
        }
    }

    /**
     * Returns the currently popped open menu.
     */
    public function getCurrentMenu () :Menu
    {
        if (_currentMenus.length == 0) {
            return null;
        }
        return _currentMenus[_currentMenus.length - 1];
    }

    /**
     * Handles the POP_GO_MENU command.
     */
    public function handlePopGoMenu (trigger :CommandButton) :void
    {
        var menuData :Array = [];
        // add standard items
        populateGoMenu(menuData);

        popControlBarMenu(menuData, trigger);
    }

    /**
     * Handles the POP_MEMBER_MENU command.
     */
    public function handlePopMemberMenu (name :String, memberId :int) :void
    {
        var menuItems :Array = [];
        // reconstitute the playerName from args
        var memName :PlayerName = new PlayerName(name, memberId);
        addMemberMenuItems(memName, menuItems);
        CommandMenu.createMenu(menuItems, _topPanel).popUpAtMouse();
    }

    /**
     * Handles the POP_CHANNEL_MENU command.
     */
    public function handlePopChannelMenu (trigger :Button) :void
    {
        const me :PlayerObject = _octx.getPlayerObject();

        var menuData :Array = [];
        menuData.push({ label: Msgs.GENERAL.get("b.clearChat"),
            callback: _chatDir.clearDisplays });
        CommandMenu.addSeparator(menuData);

        // slap your friends in a menu
        var friends :Array = [];
        for each (var fe :FriendEntry in me.getSortedFriends()) {
            // ORTH TODO: OPEN_CHANNEL is gone, do something else
    //            friends.push(
    //                { label: fe.name.toString(), command: OrthController.OPEN_CHANNEL, arg: fe.name });
        }
        if (friends.length == 0) {
            friends.push({ label: Msgs.GENERAL.get("m.no_friends"), enabled: false });
        }
        menuData.push({ label: Msgs.GENERAL.get("l.friends"), children: friends });

        popControlBarMenu(menuData.reverse(), trigger);
    }

    /**
     * Handles the VIEW_MEMBER command.
     */
    public function handleViewMember (memberId :int) :void
    {
        log.warning("VIEW_MEMBER not implemented.");
    }

    /**
     * Handles the GO_SCENE command.
     */
    public function handleGoScene (sceneId :int) :void
    {
        _sceneDir.moveTo(sceneId);
    }

    /**
     * Handles the GO_LOCATION command to go to a placeobject.
     */
    public function handleGoLocation (placeOid :int) :void
    {
        _locDir.moveTo(placeOid);
    }

    /**
     * Handles booting a user.
     */
    public function handleBootFromPlace (memberId :int) :void
    {
        log.warning("BOOT_FROM_PLACE not implemented.");
    }

    /**
     * Handles the POP_PET_MENU command.
     */
    public function handlePopPetMenu (name :String, petId :int, ownerId :int) :void
    {
        var menuItems :Array = [];
        addPetMenuItems(new PetName(name, petId, ownerId), menuItems);
        CommandMenu.createMenu(menuItems, _topPanel).popUpAtMouse();
    }

    /**
     * Handles the POP_ROOM_MENU command.
     */
    public function handlePopRoomMenu (trigger :Button) :void
    {
        var menuData :Array = [];

        CommandMenu.addTitle(menuData, _roomView.getPlaceName());

        CommandMenu.addSeparator(menuData);
        menuData.push({label: Msgs.GENERAL.get("b.editScene"), icon: _rsrc.roomEditIcon,
            command: RoomController.ROOM_EDIT,
            enabled: _roomView.getRoomController().canManageRoom() });

        menuData.push({ label: Msgs.GENERAL.get("b.snapshot"), icon: _rsrc.snapshotIcon,
            command: doSnapshot });

        popControlBarMenu(menuData, trigger);
    }

    public function addMemberMenuItems (
        name :PlayerName, menuItems :Array, addWorldItems :Boolean = true) :void
    {
        const memId :int = name.getId();
        const us :PlayerObject = _octx.getPlayerObject();
        const isUs :Boolean = (memId == us.getPlayerId());
        const isMuted :Boolean = !isUs && _muteDir.isMuted(name);
        var placeCtrl :Object = null;
        if (addWorldItems) {
            placeCtrl = _locDir.getPlaceController();
        }

        var followItem :Object = null;
        if (addWorldItems) {
            var followItems :Array = [];
            if (isUs) {
                // if we have followers, add a menu item for clearing them
                if (us.followers.size() > 0) {
                    followItems.push({ label: Msgs.GENERAL.get("b.clear_followers"),
                        callback: _orthCtrl.ditchFollower });
                }
                // if we're following someone, add a menu item for stopping
                if (us.following != null) {
                    followItems.push({ label: Msgs.GENERAL.get("b.stop_following"),
                        callback: _orthCtrl.handleRespondFollow, arg: 0 });
                }
            } else {
                // we could be following them...
                if (name.equals(us.following)) {
                    followItems.push({ label: Msgs.GENERAL.get("b.stop_following"),
                        callback: _orthCtrl.handleRespondFollow, arg: 0 });
                } else {
                    followItems.push({ label: Msgs.GENERAL.get("b.follow_other"),
                        callback: _orthCtrl.handleRespondFollow, arg: memId, enabled: !isMuted });
                }
                // and/or they could be following us...
                if (us.followers.containsKey(memId)) {
                    followItems.push({ label: Msgs.GENERAL.get("b.ditch_follower"),
                        callback: _orthCtrl.ditchFollower, arg: memId });
                } else {
                    followItems.push({ label: Msgs.GENERAL.get("b.invite_follow"),
                        callback: _orthCtrl.inviteFollow, arg: memId, enabled: !isMuted });
                }
            }
            if (followItems.length > 0) {
                followItem = { label: Msgs.GENERAL.get("l.following"), children: followItems };
            }
        }

        var icon :* = null;
        if (isUs) {
            icon = MediaWrapper.createView(
                us.playerName.getPhoto(), MediaDescSize.QUARTER_THUMBNAIL_SIZE);
    //        } else if (name is VizPlayerName) {
    //            icon = MediaWrapper.createView(
    //                VizPlayerName(name).getPhoto(), MediaDescSize.QUARTER_THUMBNAIL_SIZE);
        }
        CommandMenu.addTitle(menuItems, name.toString(), icon);
        if (isUs) {
            if (followItem != null) {
                menuItems.push(followItem);
            }

        } else {
            const onlineFriend :Boolean = us.isOnlineFriend(memId);
            const isInOurRoom :Boolean = (placeCtrl is RoomObjectController) &&
                RoomObjectController(placeCtrl).containsPlayer(name);
            // whisper
            // ORTH TODO: OPEN_CHANNEL is gone, do something else
    //            menuItems.push({
    //                label: Msgs.GENERAL.get("b.open_channel"), icon: _rsrc.whisperIcon,
    //                command: OrthController.OPEN_CHANNEL, arg: name, enabled: !muted });
            // add as friend
            if (!onlineFriend) {
                menuItems.push({
                    label: Msgs.GENERAL.get("l.add_as_friend"), icon: _rsrc.addFriendIcon,
                    command: OrthController.INVITE_FRIEND, arg: memId, enabled: !muted });
            }
            // visit
            if (onlineFriend) {
                var label :String = onlineFriend ?
                    Msgs.GENERAL.get("b.visit_friend") : "Visit (as agent)";
                menuItems.push({
                    label: label, icon: _rsrc.visitIcon, command: OrthController.VISIT_MEMBER,
                    arg: memId, enabled: !isInOurRoom });
            }
            // profile
            menuItems.push({ label: Msgs.GENERAL.get("b.view_member"),
                command: VIEW_MEMBER, arg: memId });
            // following
            if (followItem != null) {
                menuItems.push(followItem);
            }
            // partying
            // ORTH TODO
            // if (_partyDir.canInviteToParty()) {
            //     menuItems.push({ label: Msgs.PARTY.get("b.invite_member"),
            //         command: INVITE_TO_PARTY, arg: memId,
            //         enabled: !muted && !_partyDir.partyContainsPlayer(memId) });
            // }

            CommandMenu.addSeparator(menuItems);
            // muting
            var muted :Boolean = _muteDir.isMuted(name);
            menuItems.push({ label: Msgs.GENERAL.get(muted ? "b.unmute" : "b.mute"),
                icon: _rsrc.blockIcon,
                callback: _muteDir.setMuted, arg: [ name, !muted ] });
            // booting
            if (addWorldItems && isInOurRoom &&
                    (placeCtrl is BootablePlaceController) &&
                    BootablePlaceController(placeCtrl).canBoot()) {
                menuItems.push({ label: Msgs.GENERAL.get("b.boot"),
                    callback: handleBootFromPlace, arg: memId });
            }
            // reporting
            menuItems.push({ label: Msgs.GENERAL.get("b.complain"), icon: _rsrc.reportIcon,
                command: OrthController.COMPLAIN_MEMBER, arg: [ memId, name ] });
        }

        // now the items specific to the avatar
        if (addWorldItems && (placeCtrl is RoomObjectController)) {
            RoomObjectController(placeCtrl).addAvatarMenuItems(name, menuItems);
        }

        if (isUs) {
            // ORTH TODO: This needs to be redesigned entirely
            // var creds :WorldCredentials = new WorldCredentials(null, null);
            // menuItems.push({ label: Msgs.GENERAL.get("b.logout"),
            //     command: OrthController.LOGON, arg: creds });
        }
    }

    /**
     * Add pet menu items.
     */
    public function addPetMenuItems (petName :PetName, menuItems :Array) :void
    {
        // ORTH TODO
        // const ownerMuted :Boolean = _muteDir.isOwnerMuted(petName);
        const ownerMuted :Boolean = false;
        if (ownerMuted) {
            menuItems.push({ label: Msgs.GENERAL.get("b.unmute_owner"), icon: _rsrc.blockIcon,
                callback: _muteDir.setMuted,
                arg: [ new PlayerName("", petName.getOwnerId()), false ] });
        } else {
            const isMuted :Boolean = _muteDir.isMuted(petName);
            menuItems.push({ label: Msgs.GENERAL.get(isMuted ? "b.unmute_pet" : "b.mute_pet"),
                icon: _rsrc.blockIcon,
                callback: _muteDir.setMuted, arg: [ petName, !isMuted ] });
        }
    }

    /**
     * Convenience to pop a menu triggered from a button on the control bar.
     */
    protected function popControlBarMenu (menuData :Array, trigger :Button) :void
    {
        var menu :CommandMenu = CommandMenu.createMenu(menuData, _topPanel);
        menu.setBounds(_topPanel.getMainAreaBounds());
        menu.setTriggerButton(trigger);
        var r :Rectangle = trigger.getBounds(trigger.stage);
        var y :int;
        y = Math.min(r.top, _controlBar.asSprite().localToGlobal(new Point()).y);

        menu.addEventListener(MenuEvent.MENU_SHOW, handleShowMenu);
        menu.addEventListener(MenuEvent.MENU_HIDE, handleHideMenu);
        menu.popUpAt(r.left, y, true);
    }

    /**
     * Tracks when a menu is shown and updates our tracking stack.
     */
    protected function handleShowMenu (evt :MenuEvent) :void
    {
        if (_currentMenus.length == 0 || evt.menu.parentMenu == getCurrentMenu()) {
            _currentMenus.push(evt.menu);
        }
    }

    /**
     * Tracks when a menu is hidden and updates our tracking stack.
     */
    protected function handleHideMenu (evt :MenuEvent) :void
    {
        var idx :int = _currentMenus.indexOf(evt.menu);
        if (idx != -1) {
            _currentMenus.length = idx;
        }
    }

    /**
     * Populate the go menu.
     */
    protected function populateGoMenu (menuData :Array) :void
    {
        const me :PlayerObject = _octx.getPlayerObject();

        // our friends
        var friends :Array = [];
        for each (var fe :FriendEntry in me.getSortedFriends()) {
            friends.push({ label: fe.name.toString(), command: OrthController.VISIT_MEMBER,
                    arg: fe.name.getId() });
        }
        if (friends.length == 0) {
            friends.push({ label: Msgs.GENERAL.get("m.no_friends"), enabled: false });
        }
        menuData.push({ label: Msgs.GENERAL.get("l.visit_friends"), children: friends });
    }

    protected function doSnapshot () :void
    {
        // ORTH TODO
        //     if (_snapPanel == null) {
        //         _snapPanel = new SnapshotPanel();
        //         _snapPanel.addCloseCallback(function () :void {
        //             _snapPanel = null;
        //         });
        //     }
    }


    /** The number of pixels we scroll the room on a keypress. */
    protected static const ROOM_SCROLL_INCREMENT :int = 20;

    /** The amount we alter the y coordinate of tooltips generated under the mouse. */
    protected static const MOUSE_TOOLTIP_Y_OFFSET :int = 50;

    protected const _octx :OrthContext = inject(OrthContext);
    protected const _rctx :RoomContext = inject(RoomContext);

    protected const _muteDir :MuteDirector = inject(MuteDirector);
    protected const _locDir :LocationDirector = inject(LocationDirector);

    protected const _orthCtrl :OrthController = inject(OrthController);
    protected const _locusCtrl :LocusController = inject(LocusController);
    protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);
    protected const _rsrc :OrthResourceFactory = inject(OrthResourceFactory);


    protected const _aetherDir :AetherDirector = inject(AetherDirector);
    protected const _locusDir :LocusDirector = inject(LocusDirector);
    protected const _sceneDir :OrthSceneDirector = inject(SceneDirector);
    protected const _spotDir :SpotSceneDirector = inject(SpotSceneDirector);

    protected const _topPanel :TopPanel = inject(TopPanel);
    protected const _controlBar :ControlBar = inject(ControlBar);

    /** The menus that we are currently showing. */
    protected var _currentMenus :Array = [];


    /** The room view that we're controlling. */
    protected var _roomView :RoomView;

    /** Contains active throttlers. EntityIdent -> Throttler. */
    protected var _throttlers :Map = Maps.newMapOf(EntityIdent);

    protected var _throttleChecker :Timer = new Timer(500);

    /** If true, normal sprite hovering is disabled. */
    protected var _suppressNormalHovering :Boolean;

    /** The currently hovered sprite, or null. */
    protected var _hoverSprite :EntitySprite;

    /** All currently displayed sprite tips, indexed by EntitySprite. */
    protected var _hoverTips :Dictionary = new Dictionary(true);

    /** True if the shift key is currently being held down, false if not. */
    protected var _shiftDown :Boolean;

    /** If shift is being held down, the coordinates at which it was pressed. */
    protected var _shiftDownSpot :Point;

    /** Assigned to a sprite that we should not process clicks upon. */
    protected var _clickSuppress :Object;

    /** The "cursor" used to display that a location is walkable. */
    protected var _walkTarget :WalkTarget = new WalkTarget();

    protected var _flyTarget :WalkTarget = new WalkTarget(true);

//    protected var _entityAllowedToPop :EntitySprite;
}
}

import flash.display.DisplayObject;

import flashx.funk.ioc.inject;

import com.threerings.util.Log;
import com.threerings.util.Throttle;

import com.threerings.orth.client.OrthResourceFactory;
import com.threerings.orth.room.client.RoomElementSprite;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.OrthRoomCodes;

class WalkTarget extends RoomElementSprite
{
    public function WalkTarget (fly :Boolean = false)
    {
        const rsrc :OrthResourceFactory = inject(OrthResourceFactory);

        var targ :DisplayObject = (fly ? rsrc.newFlyTarget() : rsrc.newWalkTarget());
        targ.x = -targ.width/2;
        targ.y = -targ.height/2;
        addChild(targ);
    }

    override public function getRoomLayer () :int
    {
        return OrthRoomCodes.FURNITURE_LAYER;
    }

    // from RoomElement
    override public function setScreenLocation (x :Number, y :Number, scale :Number) :void
    {
        // don't let the target shrink too much - 0.25 of original size at most
        super.setScreenLocation(x, y, Math.max(0.25, scale));
    }

}

/**
 * Throttles entity communications.
 */
class Throttler
{
    public static const OPERATIONS :int = 5;
    public static const PERIOD :int = 1000;
    public static const MAX_QUEUE :int = 20;

    public static const log :Log = Log.getLog(Throttler);

    /** The ident associated with this Throttler. */
    public var ident :EntityIdent;

    public function Throttler (ident :EntityIdent)
    {
        this.ident = ident;
    }

    public function processOp (fn :Function, args :Array) :void
    {
        if (_throttle.throttleOp()) {
            if (_queue.length < MAX_QUEUE) {
                _queue.push([ fn, args ]);
                log.info("Queued entity message", "ident", ident, "queueSize", _queue.length);

            } else {
                log.warning("Dropping entity message", "ident", ident);
            }

        } else {
            fn.apply(null, args);
            //log.debug("Message not throttled", "ident", ident);
        }
    }

    public function checkOps (now :int) :void
    {
        while (_queue.length > 0) {
            if (_throttle.throttleOpAt(now)) {
                break;
            }
            var item :Array = _queue.shift() as Array;
            (item[0] as Function).apply(null, item[1] as Array);
            //log.debug("Sent queued message", "ident", ident);
        }
    }

    public function noteDrop () :void
    {
        if (_queue.length > 0) {
            log.warning("Queued messages dropped", "ident", ident, "queueSize", _queue.length);
        }
    }

    protected var _throttle :Throttle = new Throttle(OPERATIONS, PERIOD);

    protected var _queue :Array = [];
}
