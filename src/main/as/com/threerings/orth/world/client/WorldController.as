//
// $Id: WorldController.as 19431 2010-10-22 22:08:36Z zell $

package com.threerings.orth.world.client {

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.ui.Keyboard;
import flash.utils.Timer;
import flash.utils.getTimer;

import flashx.funk.ioc.inject;

import mx.controls.Button;
import mx.controls.Menu;
import mx.core.IUITextField;
import mx.events.MenuEvent;

import com.threerings.crowd.chat.client.ChatCantStealFocus;
import com.threerings.crowd.chat.client.MuteDirector;
import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.client.BodyService;
import com.threerings.crowd.client.LocationAdapter;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.CrowdCodes;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.flex.ChatControl;
import com.threerings.flex.CommandButton;
import com.threerings.flex.CommandMenu;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.data.Scene;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Controller;
import com.threerings.util.Log;
import com.threerings.util.Name;
import com.threerings.util.Util;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ClientObserver;
import com.threerings.presents.net.Credentials;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.client.ControlBar;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.OrthController;
import com.threerings.orth.client.OrthResourceFactory;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.data.MediaDescSize;
import com.threerings.orth.room.client.DisconnectedPanel;
import com.threerings.orth.room.client.RoomContext;
import com.threerings.orth.room.client.RoomController;
import com.threerings.orth.room.client.RoomObjectController;
import com.threerings.orth.room.client.RoomView;
import com.threerings.orth.room.data.PetName;
import com.threerings.orth.ui.MediaWrapper;
import com.threerings.orth.world.client.BootablePlaceController;
import com.threerings.orth.world.data.WorldCredentials;

/**
 * A persistent controller for the top UI element; this is not torn down and reconstructed
 * as we move about the world. It is a companion to OrthController that handles the directly
 * world-related activities.
 *
 * ORTH TODO: Some or much of this class needs to move into room/
 */
public class WorldController extends Controller
    implements ClientObserver
{
    /** Command to issue to toggle the chat display. */
    public static const TOGGLE_CHAT_HIDE :String = "ToggleChatHide";

    /** Command to toggle the channel occupant list display */
    public static const TOGGLE_OCC_LIST :String = "ToggleOccList";

    /** Command to edit preferences. */
    public static const CHAT_PREFS :String = "ChatPrefs";

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

    public function WorldController ()
    {
        _client.addServiceGroup(CrowdCodes.CROWD_GROUP);
        _client.addClientObserver(this);

        // create a timer to poll mouse position and track timing
        _idleTimer = new Timer(1000);
        _idleTimer.addEventListener(TimerEvent.TIMER, handlePollIdleMouse);

        // listen for location changes
        _rctx.getLocationDirector().addLocationObserver(
            new LocationAdapter(null, this.locationDidChange, null));

        setControlledPanel(_topPanel.systemManager);
        _stage.addEventListener(KeyboardEvent.KEY_DOWN, handleStageKeyDown, false, int.MAX_VALUE);
        _stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, int.MAX_VALUE);
    }

    /**
     * Are we currently idle, i.e. no input for a period of time? This precludes away-ness.
     */
    public function isIdle () :Boolean
    {
        return _idle;
    }

    /**
     * Adds a place exit handler to be invoked whenever the user requests to leave the current
     * place. The function should take no arguments and return a Boolean. A true return value means
     * carry on closing the place view. A false value means ignore the current request. In the
     * latter case, the handler ought to automatically re-close the place view when it is finished
     * with its business.
     */
    public function addPlaceExitHandler (fn :Function) :void
    {
        _placeExitHandlers.push(fn);
    }

    /**
     * Removes a previously added place exit handler.
     */
    public function removePlaceExitHandler (fn :Function) :void
    {
        ArrayUtil.removeAll(_placeExitHandlers, fn);
    }

    /**
     * Attempts to reconnect to the server and return to our starting location.
     */
    public function reconnectClient () :void
    {
        _client.logon();
    }

    // from ClientObserver
    public function clientWillLogon (event :ClientEvent) :void
    {
        // nada
    }

    // from ClientObserver
    public function clientDidLogon (event :ClientEvent) :void
    {
        var name :Name = (_client.getCredentials() as WorldCredentials).getUsername();
        if (name != null) {
            Prefs.setUsername(name.toString());
        }
    }

    // from ClientObserver
    public function clientObjectDidChange (event :ClientEvent) :void
    {
        // nada
    }

    // from ClientObserver
    public function clientDidLogoff (event :ClientEvent) :void
    {
        if (_logoffMessage != null) {
            _topPanel.setMainView(new DisconnectedPanel(_client, _logoffMessage, reconnectClient));
            _logoffMessage = null;
        } else {
            _topPanel.clearMainView();
        }
    }

    // from ClientObserver
    public function clientFailedToLogon (event :ClientEvent) :void
    {
        _topPanel.setMainView(new DisconnectedPanel(
                _client, event.getCause().message, reconnectClient));
    }

    // from ClientObserver
    public function clientConnectionFailed (event :ClientEvent) :void
    {
        _logoffMessage = "m.lost_connection";
    }

    // from ClientObserver
    public function clientWillLogoff (event :ClientEvent) :void
    {
        // nada
    }

    // from ClientObserver
    public function clientDidClear (event :ClientEvent) :void
    {
        // nada
    }

    /**
     * Can be called with nearly any event (or none) to reset the idle tracking.
     * This function is public because it may be registered as an event listener for
     * components that have access to events in a different security boundary.
     */
    public function resetIdleTracking (event :Event = null) :void
    {
        _idleStamp = getTimer();
        setIdle(false);
    }

    /**
     * Returns true if all installed exit handlers have sanctioned the closure of the place view,
     * or false if we need to abort.
     */
    public function sanctionClosePlaceView () :Boolean
    {
        // give the handlers a chance to prevent closure
        for each (var fn :Function in _placeExitHandlers.slice()) {
            var okay :Boolean = fn();
            if (!okay) {
                return false;
            }
        }
        return true;
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
     * Handles the TOGGLE_CHAT_HIDE command.
     */
    public function handleToggleChatHide () :void
    {
        Prefs.setShowingChatHistory(!Prefs.getShowingChatHistory());
    }

    /**
     * Handles the TOGGLE_OCC_LIST command.
     */
    public function handleToggleOccList () :void
    {
        Prefs.setShowingOccupantList(!Prefs.getShowingOccupantList());
    }

    /**
     * Handles CHAT_PREFS.
     */
    public function handleChatPrefs () :void
    {
        // ORTH TODO: Punted
        // new ChatPrefsDialog(_wctx);
    }

    /**
     * Handles the POP_CHANNEL_MENU command.
     */
    public function handlePopChannelMenu (trigger :Button) :void
    {
        const me :PlayerObject = _octx.getPlayerObject();

        var menuData :Array = [];
        menuData.push({ label: Msgs.GENERAL.get("b.chatPrefs"), command: CHAT_PREFS });

        // ORTH TODO
//        menuData.push({ label: Msgs.GENERAL.get("b.clearChat"), 
//            callback: _chatDir.clearAllDisplays });
        CommandMenu.addSeparator(menuData);

        menuData.push({ command: TOGGLE_CHAT_HIDE, label: Msgs.GENERAL.get(
                    Prefs.getShowingChatHistory() ? "b.hide_chat" : "b.show_chat") });

        menuData.push({ command: TOGGLE_OCC_LIST, label: Msgs.GENERAL.get(
            Prefs.getShowingOccupantList() ? "b.hide_occ_list" : "b.show_occ_list") });

        CommandMenu.addSeparator(menuData);

        // slap your friends in a menu
        var friends :Array = [];
        for each (var fe :FriendEntry in me.getSortedFriends()) {
            friends.push(
                { label: fe.name.toString(), command: OrthController.OPEN_CHANNEL, arg: fe.name });
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

        var roomView :RoomView = _topPanel.getMainView() as RoomView;

        CommandMenu.addTitle(menuData, roomView.getPlaceName());

        CommandMenu.addSeparator(menuData);
        menuData.push({label: Msgs.GENERAL.get("b.editScene"), icon: _rsrc.roomEditIcon,
            command: RoomController.ROOM_EDIT,
            enabled: roomView.getRoomController().canManageRoom() });

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
            menuItems.push({
                label: Msgs.GENERAL.get("b.open_channel"), icon: _rsrc.whisperIcon,
                command: OrthController.OPEN_CHANNEL, arg: name, enabled: !muted });
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
     * Inform our parent web page that our display name has changed.
     */
    public function refreshDisplayName () :void
    {
        try {
            if (ExternalInterface.available) {
                ExternalInterface.call("refreshDisplayName");
            }
        } catch (e :Error) {
        }
    }

    override protected function setControlledPanel (panel :IEventDispatcher) :void
    {
        _idleTimer.reset();
        super.setControlledPanel(panel);
        if (_controlledPanel != null) {
            _idleTimer.start();
            resetIdleTracking();
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
        y = Math.min(r.top, _controlBar.localToGlobal(new Point()).y);

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
     * Handles global key events.
     */
    protected function handleKeyDown (event :KeyboardEvent) :void
    {
        resetIdleTracking(event);

        switch (event.keyCode) {
        case Keyboard.F9:
            handleToggleChatHide();
            break;
        }

        // We check every keyboard event, see if it's a "word" character,
        // and then if it's not going somewhere reasonable, route it to chat.
        var c :int = event.charCode;
        if (c != 0 && !event.ctrlKey && !event.altKey &&
                // these are the ascii values for '/', a -> z,  A -> Z
                (c == 47 || (c >= 97 && c <= 122) || (c >= 65 && c <= 90))) {
            checkChatFocus();
        }
    }

    /**
     * Called when our location changes.
     */
    protected function locationDidChange (place :PlaceObject) :void
    {
    }

    protected function handlePollIdleMouse (event :TimerEvent) :void
    {
        var panel :DisplayObject = DisplayObject(_controlledPanel);
        var mousePoint :Point = new Point(panel.mouseX, panel.mouseY);
        if (_idleMousePoint == null || !_idleMousePoint.equals(mousePoint)) {
            // we are not idle: either we just started, or a key event was detected,
            // or the mouse moved.
            _idleMousePoint = mousePoint;
            resetIdleTracking();

        } else if (!isNaN(_idleStamp) && (getTimer() - _idleStamp >= ChatCodes.DEFAULT_IDLE_TIME)) {
            _idleStamp = NaN;
            setIdle(true);
        }
    }

    /**
     * Update our idle status.
     */
    protected function setIdle (nowIdle :Boolean) :void
    {
        if (nowIdle != _idle) {
            _idle = nowIdle;
            BodyService(_client.getService(BodyService)).setIdle(nowIdle);
        }
    }

    /**
     * TODO: remove someday.
     * This is a boochy workaround for the bug in flex 3.2 where some people don't get a space
     * character if they are pressing shift.
     */
    protected function handleStageKeyDown (event :KeyboardEvent) :void
    {
        if (event.shiftKey && (event.keyCode == Keyboard.SPACE) &&
                (event.target is IUITextField)) {
            var field :IUITextField = (event.target as IUITextField);
            var caretIdx :int = field.caretIndex;
            field.text = field.text.substr(0, caretIdx) + " " + field.text.substr(caretIdx);
            caretIdx++;
            field.setSelection(caretIdx, caretIdx);
            // NOTE: here, we try desperately to prevent the key from being accepted,
            // but it doesn't work: people who don't have the bug get double spaces.
            // I suspect that maybe this is because we are listening on the stage and so the
            // textfield itself may have already processed the key event?
            // Unfortunately, there doesn't seem to be a way to hook-in to the creation
            // of these text fields so that we could install a listener directly.
            event.stopImmediatePropagation();
            event.preventDefault();
        }
    }

    /**
     * Try to assign focus to the chat entry field if it seems like we should.
     */
    protected function checkChatFocus (... ignored) :void
    {
        try {
            var focus :Object = _stage.focus;
            if (!(focus is TextField) && !(focus is ChatCantStealFocus)) {
                ChatControl.grabFocus();
            }
        } catch (err :Error) {
            log.warning("Couldn't focus chat", err);
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

    protected const _octx :OrthContext = inject(OrthContext);
    // ORTH TODO: we should most certainly not refer to RoomContext in a world/ class.
    protected const _rctx :RoomContext = inject(RoomContext);
    protected const _client :WorldClient = inject(WorldClient);

    protected const _orthCtrl :OrthController = inject(OrthController);

    protected const _muteDir :MuteDirector = inject(MuteDirector);    
    protected const _locDir :LocationDirector = inject(LocationDirector);
    protected const _sceneDir :SceneDirector = inject(SceneDirector);

    protected const _stage :Stage = inject(Stage);
    protected const _topPanel :TopPanel = inject(TopPanel);
    protected const _controlBar :ControlBar = inject(ControlBar);

    protected const _rsrc :OrthResourceFactory = inject(OrthResourceFactory);

    // ORTH TODO
    // protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);
    // protected const _partyDir :OrthPartyDirector = inject(OrthPartyDirector);

    /** A scene to which to go after we logon. */
    protected var _postLogonScene :int;

    /** A special logoff message to use when we disconnect. */
    protected var _logoffMessage :String;

    /** Whether we think we're idle or not. */
    protected var _idle :Boolean = false;

    /** A timer to watch our idleness. */
    protected var _idleTimer :Timer;

    /** Used for idle tracking. */
    protected var _idleMousePoint :Point;

    protected var _idleStamp :Number;

    /** Handlers that can perform actions and/or abort the exiting of a place. */
    protected var _placeExitHandlers :Array = [];

    /** The menus that we are currently showing. */
    protected var _currentMenus :Array = [];

    /** The duration after which we log off idle guests. */
    protected static const MAX_GUEST_IDLE_TIME :int = 60*60*1000;

    private static const log :Log = Log.getLog(WorldController);
}
}
