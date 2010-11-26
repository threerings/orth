//
// $Id: WorldController.as 19431 2010-10-22 22:08:36Z zell $

package com.threerings.orth.world.client {
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthController;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.room.client.RoomObjectController;
import com.threerings.orth.room.client.RoomView;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.OrthSceneModel;

import flash.display.DisplayObject;

import flash.geom.Point;

import flash.external.ExternalInterface;

import mx.controls.Button;

import mx.styles.StyleManager;

import com.threerings.util.DelayUtil;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.Name;
import com.threerings.util.NamedValueEvent;
import com.threerings.util.StringUtil;
import com.threerings.util.ValueEvent;
import com.threerings.util.Util;

import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ClientObserver;
import com.threerings.presents.net.Credentials;

import com.threerings.crowd.client.LocationAdapter;
import com.threerings.crowd.client.PlaceView;

import com.threerings.crowd.data.PlaceObject;

import com.threerings.media.AudioPlayer;
import com.threerings.media.MediaPlayerCodes;
import com.threerings.media.Mp3AudioPlayer;

import com.threerings.flex.CommandMenu;

import com.threerings.whirled.data.Scene;

import com.threerings.orth.client.Resources;


/**
 * Extends the WorldController with World specific bits.
 */
public class WorldController
    implements ClientObserver
{
    /** Command to show the 'about' dialog. */
    public static const ABOUT :String = "About";

    /** Command to close the current place view. */
    public static const CLOSE_PLACE_VIEW :String = "ClosePlaceView";

    /** Command to move back to the previous location. */
    public static const MOVE_BACK :String = "MoveBack";

    /** Command to view change the full screen mode. Args: null or none to toggle, else
     * the StageDisplayState constant. */
    public static const SET_DISPLAY_STATE :String = "SetDisplayState";

    /** Command to issue to toggle the chat display. */
    public static const TOGGLE_CHAT_HIDE :String = "ToggleChatHide";

    /** Command to issue to toggle the chat being in a sidebar. */
    public static const TOGGLE_CHAT_SIDEBAR :String = "ToggleChatSidebar";

    /** Command to toggle the channel occupant list display */
    public static const TOGGLE_OCC_LIST :String = "ToggleOccList";

    /** Command to log us on. */
    public static const LOGON :String = "Logon";

    /** Command to edit preferences. */
    public static const CHAT_PREFS :String = "ChatPrefs";

    /** Command to display a simplified menu for muting/etc a member. */
    public static const POP_MEMBER_MENU :String = "PopMemberMenu";

    /** Command to display a simplified menu for muting/etc a pet. */
    // nada here. Pets only exist in world, but we handle them generically
    public static const POP_PET_MENU :String = "PopPetMenu";

    /** Command to show an (external) URL. */
    public static const VIEW_URL :String = "ViewUrl";

    /** Command to view an item, arg is an ItemIdent. */
    public static const VIEW_ITEM :String = "ViewItem";

    /** Command to flag an item, arg is an ItemIdent. */
    public static const FLAG_ITEM :String = "FlagItem";

    /** Command to display the full Whirled (used in the embedded client). */
    public static const VIEW_FULL_VERSION :String = "ViewFullVersion";

    /** Command to display the comment page for the current scene or game. */
    public static const VIEW_COMMENT_PAGE :String = "ViewCommentPage";

    /** Command to view a member's profile, arg is [ memberId ] */
    public static const VIEW_MEMBER :String = "ViewMember";

    /** Command to view a groups's page, arg is [ groupId ] */
    public static const VIEW_GROUP :String = "ViewGroup";

    /** Command to view a groups's discussions, arg is [ groupId ] */
    public static const VIEW_DISCUSSIONS :String = "ViewDiscussions";

    /** Command to go to a group's home scene. */
    public static const GO_GROUP_HOME :String = "GoGroupHome";

    /** Command to ensure that the share dialog is up. */
    public static const POP_SHARE_DIALOG :String = "PopShareDialog";

    /** Command to indicate an audio item was clicked, arg is [ mediaDesc ] */
    public static const AUDIO_CLICKED :String = "AudioClicked";

    /** Command to show users the subscribe page. */
    public static const SUBSCRIBE :String = "Subscribe";

    /** Command to display the chat channel menu. */
    public static const POP_CHANNEL_MENU :String = "PopChannelMenu";

    /** Command to display the room menu. */
    public static const POP_ROOM_MENU :String = "PopRoomMenu";

    /** Opens up a new toolbar and a new room editor. */
    public static const ROOM_EDIT :String = "RoomEdit";

    /** Command to rate the current scene. */
    public static const ROOM_RATE :String = "RoomRate";

    /** Command to go to a particular place (by Oid). */
    public static const GO_LOCATION :String = "GoLocation";

    /** Command to go to a particular scene. */
    public static const GO_SCENE :String = "GoScene";

    /** Command to go to a member's home scene. */
    public static const GO_MEMBER_HOME :String = "GoMemberHome";

    /** Command to invite someone to be a friend. */
    public static const INVITE_FRIEND :String = "InviteFriend";

    /** Command to open the chat interface for a particular chat channel. */
    public static const OPEN_CHANNEL :String = "OpenChannel";

    /** Command to visit a member's current location */
    public static const VISIT_MEMBER :String = "VisitMember";

    /** Command to view a "stuff" page. Arg: [ itemType ] */
    public static const VIEW_STUFF :String = "ViewStuff";

    /** Command to view a "shop" page.
     * Args: nothing to view the general shop,
     * or [ itemType ] to view a category
     * or [ itemType, itemId ] to view a specific listing. */
    public static const VIEW_SHOP :String = "ViewShop";

    /** Command to view the "mail" page. */
    public static const VIEW_MAIL :String = "ViewMail";

    /** Command to issue an invite to a current guest. */
    public static const INVITE_GUEST :String = "InviteGuest";

    /** Command to respond to a request to follow another player. */
    public static const RESPOND_FOLLOW :String = "RespondFollow";

    /** Command to open the account creation UI. */
    public static const CREATE_ACCOUNT :String = "CreateAccount";

    /** Command to complain about a member. */
    public static const COMPLAIN_MEMBER :String = "ComplainMember";

    /** Command to invoke when the featured place was clicked. */
    public static const FEATURED_PLACE_CLICKED :String = "FeaturedPlaceClicked";

    /** Command to view the passport page. */
    public static const VIEW_PASSPORT :String = "ViewPassport";

    /** Command to play music. Arg: null to stop, or [ Audio, playCounter (int) ] */
    public static const PLAY_MUSIC :String = "PlayMusic";

    /** Get info about the currently-playing music. */
    public static const MUSIC_INFO :String = "MusicInfo";

    /** Command to join a party. */
    public static const JOIN_PARTY :String = "JoinParty";

    /** Command to invite a member to the current party. */
    public static const INVITE_TO_PARTY :String = "InviteToParty";

    /** Command to request detailed info on a party. */
    public static const GET_PARTY_DETAIL :String = "GetPartyDetail";

    // statically reference classes we require
    ItemMarshaller;

    public function WorldController (ctx :WorldContext, topPanel :TopPanel)
    {
        _wctx = ctx;

        _wctx.getClient().addServiceGroup(CrowdCodes.CROWD_GROUP);
        _wctx.getClient().addClientObserver(this);
        _topPanel = topPanel;

        // create a timer to poll mouse position and track timing
        _idleTimer = new Timer(1000);
        _idleTimer.addEventListener(TimerEvent.TIMER, handlePollIdleMouse);

        // create a timer that checks whether we should be logged out for being idle too long
        _byebyeTimer = new Timer(MAX_GUEST_IDLE_TIME, 1);
        _byebyeTimer.addEventListener(TimerEvent.TIMER, checkIdleLogoff);

        // listen for location changes
        _wctx.getLocationDirector().addLocationObserver(
            new LocationAdapter(null, this.locationDidChange, null));

        var stage :Stage = mctx.getStage();
        setControlledPanel(topPanel.systemManager);
//        stage.addEventListener(FocusEvent.FOCUS_OUT, handleUnfocus);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, handleStageKeyDown, false, int.MAX_VALUE);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, int.MAX_VALUE);

        Prefs.events.addEventListener(Prefs.BLEEPED_MEDIA, handleBleepChange, false, 0, true);
        Prefs.events.addEventListener(Prefs.PREF_SET, handleConfigValueSet, false, 0, true);
        _musicPlayer.addEventListener(MediaPlayerCodes.METADATA, handleMusicMetadata);
    }

    /**
     * Returns information about the place or places the user is currently in.
     */
    public function getPlaceInfo () :PlaceInfo
    {

        var plinfo :PlaceInfo = new PlaceInfo();

        var scene :Scene = _wctx.getSceneDirector().getScene();
        plinfo.sceneId = (scene == null) ? 0 : scene.getId();
        plinfo.sceneName = (scene == null) ? null : scene.getName();

        return plinfo;
    }

    /**
     * Can we "manage" the current place.
     */
    public function canManagePlace () :Boolean
    {
        // support can manage any place...
        if (_wctx.getTokens().isSupport()) {
            return true;
        }

        const view :Object = _topPanel.getPlaceView();
        if (view is RoomView) {
            return RoomView(view).getRoomController().canManageRoom();
        }

        return false;
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
        _didFirstLogonGo = false;

        if (_wctx.getOrthClient().getEmbedding().hasGWT() && ExternalInterface.available) {
            ExternalInterface.call("rebootFlashClient");
        } else {
            _wctx.getClient().logon();
        }
    }

    // from ClientObserver
    public function clientWillLogon (event :ClientEvent) :void
    {
        // nada
    }

    // from ClientObserver
    public function clientDidLogon (event :ClientEvent) :void
    {
        var memberObj :MemberObject = _wctx.getMemberObject();
        // if not a permaguest, save the username that we logged in with
        if (!memberObj.isPermaguest()) {
            var name :Name = (_wctx.getClient().getCredentials() as MsoyCredentials).getUsername();
            if (name != null) {
                Prefs.setUsername(name.toString());
            }
        }

        if (!_didFirstLogonGo) {
            _didFirstLogonGo = true;
            goToPlace(MsoyParameters.get());
        } else if (_postLogonScene != 0) {
            // we gotta go somewhere
            _wctx.getSceneDirector().moveTo(_postLogonScene);
            _postLogonScene = 0;
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
            _topPanel.setPlaceView(new DisconnectedPanel(
                _wctx.getClient(), _logoffMessage, reconnectClient));
            _logoffMessage = null;
        } else {
            _topPanel.setPlaceView(new BlankPlaceView(_wctx));
        }
    }

    // from ClientObserver
    public function clientFailedToLogon (event :ClientEvent) :void
    {
        _topPanel.setPlaceView(new DisconnectedPanel(
            _wctx.getClient(), event.getCause().message, reconnectClient));
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
     * Convenience method for opening an external window and showing the specified url. This is
     * done when we want to show the user something without unloading the msoy world.
     *
     * Also, handles VIEW_URL.
     *
     * @param url The url to show
     * @param windowOrTab the identifier of the tab to use, like _top or _blank, or null to
     * use the default, which is the same as _blank, I think. :)
     *
     * @return true on success
     */
    public function handleViewUrl (url :String, windowOrTab :String = null) :Boolean
    {
        // if our page refers to a Whirled page...
        var gwtPrefix :String = DeploymentConfig.serverURL + "#";
        var gwtUrl :String;
        if (url.indexOf(gwtPrefix) == 0) {
            gwtUrl = url.substring(gwtPrefix.length);
        } else if (url.indexOf("#") == 0) {
            gwtUrl = url.substring(1);
        } else if (NetUtil.navigateToURL(url, windowOrTab)) {
            return true;
        } else {
            _wctx.displayFeedback(
                OrthCodes.GENERAL_MSGS, MessageBundle.tcompose("e.no_navigate", url));

            // TODO
            // experimental: display a popup with the URL (this could be moved to handleLink()
            // if this method is altered to return a success Boolean
            new MissedURLDialog(_wctx, url);
            return false;
        }

        // ...extract the page and arguments and tell GWT to display them properly
        var didx :int = gwtUrl.indexOf("-");
        if (didx == -1) {
            return displayPage(gwtUrl, "");
        } else {
            return displayPage(gwtUrl.substring(0, didx), gwtUrl.substring(didx+1));
        }
    }


    /**
     * Handles the POP_GO_MENU command.
     */
    public function handlePopGoMenu (trigger :CommandButton) :void
    {
        var menuData :Array = [];
        // add standard items
        populateGoMenu(menuData);
        // on the header, add the back link
        menuData.push({ label: Msgs.GENERAL.get("b.back"), callback: handleMoveBack,
            enabled: canMoveBack() });

        popControlBarMenu(menuData, trigger);
    }

    /**
     * Handles the POP_MEMBER_MENU command.
     */
    public function handlePopMemberMenu (name :String, memberId :int) :void
    {
        var menuItems :Array = [];
        // reconstitute the memberName from args
        var memName :OrthName = new OrthName(name, memberId);
        addMemberMenuItems(memName, menuItems);
        CommandMenu.createMenu(menuItems, _wctx.getTopPanel()).popUpAtMouse();
    }

    /**
     * Handles the ABOUT command.
     */
    public function handleAbout () :void
    {
        new AboutDialog(_wctx);
    }

    /**
     * Handles the CLOSE_PLACE_VIEW command.
     */
    public function handleClosePlaceView () :void
    {
        // give the handlers a chance to prevent closure
        if (!sanctionClosePlaceView()) {
            return;
        }
        // if we're in the whirled, closing means closing the flash client totally
        _wctx.getOrthClient().closeClient();
    }

    /**
     * Handles the MOVE_BACK command.
     */
    public function handleMoveBack (closeInsteadOfHome :Boolean = false) :void
    {
        // go to the first recent scene that's not the one we're in
        const curSceneId :int = getCurrentSceneId();
        for each (var entry :Object in _recentScenes) {
            if (entry.id != curSceneId) {
                handleGoScene(entry.id);
                return;
            }
        }

        // there are no recent scenes, so go home
        handleGoScene(_wctx.getMemberObject().getHomeSceneId());
    }

    /**
     * Handles the POP_SHARE_DIALOG command.
     */
    public function handlePopShareDialog () :void
    {
        // do it this way so that we don't mess up the dialog popper.
        if (!_wctx.getControlBar().shareBtn.selected) {
            _wctx.getControlBar().shareBtn.activate();
        }
    }

    /**
     * Can we move back?
     */
    public function canMoveBack () :Boolean
    {
        // you can only NOT move back if you are in your home room and there are no
        // other scenes in your history
        const curSceneId :int = getCurrentSceneId();
        var memObj :MemberObject = _wctx.getMemberObject();
        if (memObj == null) {
            return false;
        }
        if (memObj.getHomeSceneId() != curSceneId) {
            return true;
        }
        for each (var entry :Object in _recentScenes) {
            if (entry.id != curSceneId) {
                return true;
            }
        }
        return false;

    }

    /**
     * Handles the SET_DISPLAY_STATE command.
     */
    public function handleSetDisplayState (state :String = null) :void
    {
        const stage :Stage = _wctx.getStage();
        const curState :String = stage.displayState;
        if (state == curState) {
            return;
        }
        if (state == null) {
            state = (curState == StageDisplayState.NORMAL) ? StageDisplayState.FULL_SCREEN
                                                           : StageDisplayState.NORMAL;
        }
        try {
            stage.displayState = state;
        } catch (se :SecurityError) {
            // it didn't work! Disable the full-screen button
            _wctx.getControlBar().fullBtn.enabled = false;
        }
    }

    /**
     * Handles the TOGGLE_CHAT_HIDE command.
     */
    public function handleToggleChatHide () :void
    {
        Prefs.setShowingChatHistory(!Prefs.getShowingChatHistory());
    }

    /**
     * Handles the TOGGLE_CHAT_SIDEBAR command.
     */
    public function handleToggleChatSidebar () :void
    {
        Prefs.setSidebarChat(!Prefs.getSidebarChat());
    }

    /**
     * Handles the TOGGLE_OCC_LIST command.
     */
    public function handleToggleOccList () :void
    {
        Prefs.setShowingOccupantList(!Prefs.getShowingOccupantList());
    }

    /**
     * Handles the LOGON command.
     */
    public function handleLogon (creds :Credentials) :void
    {
        // if we're currently logged on, save our current scene so that we can go back there once
        // we're relogged on as a non-guest; otherwise go to Brave New Whirled
        const currentSceneId :int = getCurrentSceneId();
        _postLogonScene = (currentSceneId == 0) ? 1 : currentSceneId;
        _wctx.getClient().logoff(false);

        // give the client a chance to log off, then log back on
        _topPanel.callLater(function () :void {
            var client :Client = _wctx.getClient();
            log.info("Logging on", "creds", creds, "version", DeploymentConfig.version);
            client.setCredentials(creds);
            client.logon();
        });
    }

    /**
     * Handles CHAT_PREFS.
     */
    public function handleChatPrefs () :void
    {
        new ChatPrefsDialog(_wctx);
    }

    public function handleAudioClicked (desc :MediaDesc, ident :ItemIdent) :void
    {
        if (desc == null || !desc.isBleepable()) {
            return;
        }

        var mediaId :String = desc.getMediaId();
        var kind :String = Msgs.GENERAL.get(Item.getTypeKey(Item.AUDIO));
        var menuItems :Array = [];
        menuItems.push({ label: Msgs.GENERAL.get("b.view_item", kind),
            command: OrthController.VIEW_ITEM, arg: ident });
        if (_wctx.isRegistered()) {
            menuItems.push({ label: Msgs.GENERAL.get("b.flag_item", kind),
                command: OrthController.FLAG_ITEM, arg: ident });
        }
        if (desc.isBleepable()) {
            var isBleeped :Boolean = Prefs.isMediaBleeped(mediaId);
            var key :String = isBleeped ? "b.unbleep_item" : "b.bleep_item";
            menuItems.push({ label: Msgs.GENERAL.get(key, kind),
                callback: Prefs.setMediaBleeped, arg: [ mediaId, !isBleeped ] });
        }

        CommandMenu.createMenu(menuItems, _topPanel).popUpAtMouse();
    }

    /**
     * Handles the OPEN_CHANNEL command.
     */
    public function handleOpenChannel (name :Name) :void
    {
        _wctx.getMsoyChatDirector().openChannel(name);
    }

    /**
     * Handles the POP_CHANNEL_MENU command.
     */
    public function handlePopChannelMenu (trigger :Button) :void
    {
        // if we don't yet have a member object, it's too early to pop!
        const me :MemberObject = _wctx.getMemberObject();
        if (me == null) {
            return;
        }

        var menuData :Array = [];
        menuData.push({ label: Msgs.GENERAL.get("b.chatPrefs"), command: CHAT_PREFS });
        menuData.push({ label: Msgs.GENERAL.get("b.clearChat"),
            callback: _wctx.getMsoyChatDirector().clearAllDisplays });
        CommandMenu.addSeparator(menuData);

        const place :PlaceView = _wctx.getPlaceView();

        menuData.push({ command: TOGGLE_CHAT_HIDE, label: Msgs.GENERAL.get(
                    Prefs.getShowingChatHistory() ? "b.hide_chat" : "b.show_chat") });

        menuData.push({ command: TOGGLE_CHAT_SIDEBAR, label: Msgs.GENERAL.get(
            Prefs.getSidebarChat() ? "b.overlay_chat" : "b.sidebar_chat") });
        menuData.push({ command: TOGGLE_OCC_LIST, label: Msgs.GENERAL.get(
            Prefs.getShowingOccupantList() ? "b.hide_occ_list" : "b.show_occ_list") });

        CommandMenu.addSeparator(menuData);

        // slap your friends in a menu
        var friends :Array = [];
        for each (var fe :FriendEntry in me.getSortedFriends()) {
            friends.push({ label: fe.name.toString(), command: OPEN_CHANNEL, arg: fe.name });
        }
        if (friends.length == 0) {
            friends.push({ label: Msgs.GENERAL.get("m.no_friends"), enabled: false });
        }
        menuData.push({ label: Msgs.GENERAL.get("l.friends"), children: friends });

        var groups :Array = (me.groups != null) ? me.getSortedGroups() : [];
        groups = groups.map(function (gm :GroupMembership, index :int, array :Array) :Object {
            return { label: gm.group.toString(), command: OPEN_CHANNEL, arg: gm.group };
        });
        if (groups.length == 0) {
            groups.push({ label: Msgs.GENERAL.get("m.no_groups"),
                          enabled : false });
        } else if (groups.length > 4) {
            menuData.push({ label: Msgs.GENERAL.get("l.groups"), children: groups});
        } else {
            menuData = menuData.concat(groups);
        }

        popControlBarMenu(menuData.reverse(), trigger);
    }

    /**
     * Handles the POP_ROOM_MENU command.
     */
    public function handlePopRoomMenu (trigger :Button) :void
    {
        var menuData :Array = [];

        var roomView :RoomView = _wctx.getPlaceView() as RoomView;

        CommandMenu.addTitle(menuData, roomView.getPlaceName());
        var scene :OrthScene = _wctx.getSceneDirector().getScene() as OrthScene;
        if (scene != null) {
            var model :OrthSceneModel = scene.getSceneModel() as OrthSceneModel;
//            if (model.ownerType == OrthSceneModel.OWNER_TYPE_GROUP) {
//                menuData.push({ label: Msgs.GENERAL.get("b.group_page"),
//                    command: WorldController.VIEW_GROUP, arg: model.ownerId });
//            }
        }

        CommandMenu.addSeparator(menuData);
        menuData.push({ label: Msgs.GENERAL.get("b.editScene"), icon: Resources.ROOM_EDIT_ICON,
            command: ROOM_EDIT, enabled: roomView.getRoomController().canManageRoom() });

        addFrameColorOption(menuData);

        menuData.push({ label: Msgs.GENERAL.get("b.viewItems"),
            callback: roomView.viewRoomItems });
        menuData.push({ label: Msgs.GENERAL.get("b.comment"), icon: CommentButton,
            command: WorldController.VIEW_COMMENT_PAGE });
        menuData.push({ label: Msgs.GENERAL.get("b.snapshot"), icon: SNAPSHOT_ICON,
            command: doSnapshot });
        menuData.push({ label: Msgs.GENERAL.get("b.music"), icon: Resources.MUSIC_ICON,
            command: DelayUtil.delayFrame, arg: [ doShowMusic, [ trigger ] ],
            enabled: (_music != null) }); // pop it later so that it avoids the menu itself

        popControlBarMenu(menuData, trigger);
    }

    /**
     * Handles the VIEW_ITEM command.
     */
    public function handleViewItem (ident :ItemIdent) :void
    {
        var resultHandler :Function = function (result :Object) :void {
            if (result == null) {
                // it's an object we own, or it's not listed but we are support+
                displayPage("stuff", "d_" + ident.type + "_" + ident.itemId);

            } else if (result == 0) {
                _wctx.displayFeedback(OrthCodes.ITEM_MSGS,
                    MessageBundle.compose("m.not_listed", Item.getTypeKey(ident.type)));

            } else {
                displayPage("shop", "l_" + ident.type + "_" + result);
            }
        };
        var isvc :ItemService = _wctx.getClient().requireService(ItemService) as ItemService;
        isvc.getCatalogId(ident, _wctx.resultListener(resultHandler));
    }

    /**
     * Handles the FLAG_ITEM command.
     */
    public function handleFlagItem (ident :ItemIdent) :void
    {
        new FlagItemDialog(_wctx, ident);
    }

    /**
     * Handles the VIEW_MEMBER command.
     */
    public function handleViewMember (memberId :int) :void
    {
        displayPage("people", "" + memberId);
    }

    /**
     * Handles hte VISIT_MEMBER command.
     */
    public function handleVisitMember (memberId :int) :void
    {
        _wctx.getWorldDirector().goToMemberLocation(memberId);
    }

    /**
     * Handles the VIEW_GROUP command.
     */
    public function handleViewGroup (groupId :int) :void
    {
        displayPage("groups", "d_" + groupId);
    }

    /**
     * Handles the VIEW_DISCUSSIONS command.
     */
    public function handleViewDiscussions (groupId :int) :void
    {
        displayPage("groups", "f_" + groupId);
    }

    /**
     * Handles the VIEW_ROOM command.
     */
    public function handleViewRoom (sceneId :int) :void
    {
        displayPage("rooms", "room_" + sceneId);
    }

    /**
     * Handles the VIEW_COMMENT_PAGE command.
     */
    public function handleViewCommentPage () :void
    {
        const sceneId :int = getCurrentSceneId();
        if (sceneId != 0) {
            handleViewRoom(sceneId);
            return;
        }
    }

    /**
     * Handles the VIEW_FULL_VERSION command, used in embedded clients.
     */
    public function handleViewFullVersion () :void
    {
        // then go to the appropriate place..
        const sceneId :int = getCurrentSceneId();
        if (sceneId != 0) {
            displayPage("world", "s" + sceneId);

        } else {
            displayPage("", "");
        }
    }

    /**
     * Handles the FEATURED_PLACE_CLICKED command.
     */
    public function handleFeaturedPlaceClicked () :void
    {
        if (_wctx.getOrthClient().isEmbedded()) {
            handleViewFullVersion();
        } else {
            var sceneId :int = getCurrentSceneId();
            if (sceneId == 0) {
                // TODO: before falling back to the initial scene, we should try
                // any pending scene...
                sceneId = int(MsoyParameters.get()["sceneId"]);
            }
            handleGoScene(sceneId);
        }
    }

    /**
     * Handles the VIEW_PASSPORT command.
     */
    public function handleViewPassport () :void
    {
        displayPage("me", "passport");
    }

    /**
     * Handles the VIEW_STUFF command.
     */
    public function handleViewStuff (itemType :int) :void
    {
        displayPage("stuff", ""+itemType);
    }

    /**
     * Handles the VIEW_SHOP command.
     */
    public function handleViewShop (itemType :int = Item.NOT_A_TYPE, itemId :int = 0) :void
    {
        var page :String = "";
        if (itemType != Item.NOT_A_TYPE) {
            page += (itemId == 0) ? itemType : ("l_" + itemType + "_" + itemId);
        }
        displayPage("shop", page);
    }

    /**
     * Handles the VIEW_MAIL command.
     */
    public function handleViewMail () :void
    {
        displayPage("mail", "");
    }

    /**
     * Handles the SHOW_SIGN_UP command.
     */
    public function handleShowSignUp () :void
    {
        displayPage("account", "create");
    }

    /**
     * Handles the GO_SCENE command.
     */
    public function handleGoScene (sceneId :int) :void
    {
        _wctx.getSceneDirector().moveTo(sceneId);
    }

    /**
     * Handles the GO_MEMBER_HOME command.
     */
    public function handleGoMemberHome (memberId :int) :void
    {
        _wctx.getWorldDirector().goToMemberHome(memberId);
    }

    /**
     * Handles the JOIN_PARTY command.
     */
    public function handleJoinParty (partyId :int) :void
    {
        _wctx.getPartyDirector().joinParty(partyId);
    }

    /**
     * Handles the GET_PARTY_DETAIL command.
     */
    public function handleGetPartyDetail (partyId :int) :void
    {
        _wctx.getPartyDirector().getPartyDetail(partyId);
    }

    /**
     * Handles the GO_GROUP_HOME command.
     */
    public function handleGoGroupHome (groupId :int) :void
    {
        _wctx.getWorldDirector().goToGroupHome(groupId);
    }

    /**
     * Handles the GO_LOCATION command to go to a placeobject.
     */
    public function handleGoLocation (placeOid :int) :void
    {
        _wctx.getLocationDirector().moveTo(placeOid);
    }

    /**
     * Handles INVITE_FRIEND.
     */
    public function handleInviteFriend (memberId :int) :void
    {
        _wctx.getMemberDirector().inviteToBeFriend(memberId);
    }

    /**
     * Handles RESPOND_FOLLOW.
     * Arg can be 0 to stop us from following anyone
     */
    public function handleRespondFollow (memberId :int) :void
    {
        WorldService(_wctx.getClient().requireService(WorldService)).
            followMember(memberId, _wctx.listener());
    }

    /**
     * Handle the ROOM_EDIT command.
     */
    public function handleRoomEdit () :void
    {
        (_topPanel.getPlaceView() as RoomObjectView).getRoomObjectController().handleRoomEdit();
    }

    /**
     * Handle the ROOM_RATE command.
     */
    public function handleRoomRate (rating :Number) :void
    {
        (_topPanel.getPlaceView() as RoomObjectView).getRoomObjectController().
                handleRoomRate(rating);
    }

    /**
     * Handles the CREATE_ACCOUNT command (generated by the InviteOverlay).
     */
    public function handleCreateAccount (invite :String = null) :void
    {
        displayPage("account", (invite == null) ? "create" : ("create_" + invite));
    }

    /**
     * Handles the COMPLAIN_MEMBER command.
     */
    public function handleComplainMember (memberId :int, username :String) :void
    {
        var service :Function = function (complaint :String) :void {
            msvc().complainMember(memberId, complaint);
        };

        _topPanel.callLater(function () :void { new ComplainDialog(_wctx, username, service); });
    }

    /**
     * Handles booting a user.
     */
    public function handleBootFromPlace (memberId :int) :void
    {
        var svc :MemberService = _wctx.getClient().requireService(MemberService) as MemberService;
        svc.bootFromPlace(memberId, _wctx.confirmListener());
    }

    /**
     * Handles PLAY_MUSIC.
     */
    public function handlePlayMusic (music :Audio) :void
    {
        if (!Util.equals(music, _music)) {
            _musicInfoShown = false;
        }
        _music = music;

        _musicPlayer.unload();

        const play :Boolean = UberClient.isRegularClient() && (music != null) &&
            (Prefs.getSoundVolume() > 0) && !isMusicBleeped();
        if (play) {
            _musicPlayer.load(music.audioMedia.getMediaPath(),
                [ music.audioMedia, music.getIdent() ]);
        }
        if (music == null && _musicDialog != null) {
            _musicDialog.close();
        }
    }

    /**
     * Handles MUSIC_INFO.
     */
    public function handleMusicInfo () :void
    {
        handleViewItem(_music.getIdent());
    }

    /**
     * Handles INVITE_TO_PARTY.
     */
    public function handleInviteToParty (memberId :int) :void
    {
        _wctx.getPartyDirector().inviteMember(memberId);
    }

    /**
     * Access the music player. Don't be too nefarious now boys!
     */
    public function getMusicPlayer () :AudioPlayer
    {
        return _musicPlayer;
    }

    /**
     * Handles the POP_PET_MENU command.
     */
    public function handlePopPetMenu (name :String, petId :int, ownerId :int) :void
    {
        var menuItems :Array = [];
        addPetMenuItems(new PetName(name, petId, ownerId), menuItems);
        CommandMenu.createMenu(menuItems, _mctx.getTopPanel()).popUpAtMouse();
    }

    /**
     * Handles SUBSCRIBE.
     */
    public function handleSubscribe () :void
    {
        displayPage("billing", "subscribe");
    }

    /**
     * Displays a new page by reloading the current web page with
     * the full GWT application, restoring our current location and then displaying the page.
     */
    public function displayPage (page :String, args :String) :Boolean
    {
        if (inGWTApp()) {
            return displayPageGWT(page, args);
        }

        // otherwise we're embedded and we need to route through the swizzle servlet to stuff our
        // session token into a cookie which will magically authenticate us with GWT
        const ptoken :String = page + (StringUtil.isBlank(args) ? "" : ("-" + args));
        const stoken :String = (_wctx.getClient().getCredentials() as MsoyCredentials).sessionToken;
        const url :String = DeploymentConfig.serverURL + "swizzle/" + stoken + "/" + ptoken;
        log.info("Showing external URL " + url);
        return super.handleViewUrl(url, null);
    }

    /**
     * Displays a new page at a given address either in our GWT application or by reloading the
     * current web page with the full GWT application, restoring our current location and then
     * displaying the page.
     */
    public function displayAddress (address :Address) :Boolean
    {
        if (address.page != null) {
            return displayPage(address.page.path, Args.join.apply(null, address.args));
        } else {
            return handleViewUrl(address.args.join("/"));
        }
    }

    /**
     * Returns the current sceneId, or 0 if none.
     */
    public function getCurrentSceneId () :int
    {
        const scene :Scene = _wctx.getSceneDirector().getScene();
        return (scene == null) ? 0 : scene.getId();
    }

    /**
     * Called by the scene director when we've traveled to a new scene.
     */
    public function wentToScene (sceneId :int) :void
    {
        if (UberClient.isFeaturedPlaceView()) {
            return;
        }
        // this will result in another request to move to the scene we're already in, but we'll
        // ignore it because we're already there
        if (!_suppressTokenForScene) {
            displayPageGWT("world", "s" + sceneId);
        }
        _suppressTokenForScene = false;
    }

    /**
     * Convienience function to restore our GWT page URL for the current scene.
     */
    public function restoreSceneURL () :void
    {
        const sceneId :int = getCurrentSceneId();
        if (sceneId != 0) {
            displayPageGWT("world", "s" + sceneId);
        }
    }

    /**
     * Figure out where we should be going, and go there.
     */
    public function goToPlace (params :Object) :void
    {
        // first, see if we should hit a specific scene
        if (null != params["memberHome"]) {
            _suppressTokenForScene = true;
            var memberId :int = int(params["memberHome"]);
            if (memberId == 0) {
                // let's take this as a signal that we're after our own home room
                memberId = _wctx.getMemberObject().getMemberId();
            }
            handleGoMemberHome(memberId);

        } else if (null != params["groupHome"]) {
            _suppressTokenForScene = true;
            handleGoGroupHome(int(params["groupHome"]));

        } else if (null != params["memberScene"]) {
            _suppressTokenForScene = true;
            handleVisitMember(int(params["memberScene"]));

        } else if (null != params["noplace"]) {
            // go to no place- we just want to chat with our friends
            _wctx.setPlaceView(new NoPlaceView());

        } else if (null != params["groupChat"]) {
            var groupId :int = int(params["groupChat"]);
            var gm :GroupMembership =
                _wctx.getMemberObject().groups.get(groupId) as GroupMembership;
            if (gm != null) {
                handleOpenChannel(gm.group);
            }

        } else if (null != params["sceneId"]) {
            var sceneId :int = int(params["sceneId"]);
            if (sceneId == 0) {
                log.warning("Moving to scene 0, I hope that's what we actually want.",
                    "raw arg", params["sceneId"]);
                //sceneId = _wctx.getMemberObject().getHomeSceneId();
            }
            _wctx.getSceneDirector().moveTo(sceneId);

            // if we have a redirect page we need to show, do that (we do this by hand to avoid
            // potential infinite loops if something goes awry with opening external pages)
            try {
                var redirect :String = params["page"];
                if (redirect != null && ExternalInterface.available) {
                	var args :String = params["args"] == null ? "" : params["args"];
                    ExternalInterface.call("displayPage", redirect, args);
                }
            } catch (error :Error) {
                // nothing we can do here...
            }

        } else {
            // go to our home scene (this doe the right thing for guests as well)
            _wctx.getSceneDirector().moveTo(_wctx.getMemberObject().getHomeSceneId());
        }
    }

    /**
     * Show (or hide) the tables waiting display.
     */
    public function showTablesWaiting (show :Boolean = true) :void
    {
        if (show) {
            if (_tablesPanel == null) {
                _tablesPanel = new TablesWaitingPanel(_wctx);
                _tablesPanel.addCloseCallback(function () :void {
                    _tablesPanel = null;
                });
                _tablesPanel.open();
            } else {
                _tablesPanel.refresh();
            }

        } else if (_tablesPanel != null) {
            _tablesPanel.close();
        }
    }

    public function addMemberMenuItems (
        name :OrthName, menuItems :Array, addWorldItems :Boolean = true) :void
    {
        const memId :int = name.getMemberId();
        const us :MemberObject = _wctx.getMemberObject();
        const isUs :Boolean = (memId == us.getMemberId());
        const isMuted :Boolean = !isUs && _wctx.getMuteDirector().isMuted(name);
        const isSupport :Boolean = _wctx.getTokens().isSupport();
        var placeCtrl :Object = null;
        if (addWorldItems) {
            placeCtrl = _wctx.getLocationDirector().getPlaceController();
        }

        var followItem :Object = null;
        if (addWorldItems) {
            var followItems :Array = [];
            if (isUs) {
                // if we have followers, add a menu item for clearing them
                if (us.followers.size() > 0) {
                    followItems.push({ label: Msgs.GENERAL.get("b.clear_followers"),
                        callback: ditchFollower });
                }
                // if we're following someone, add a menu item for stopping
                if (us.following != null) {
                    followItems.push({ label: Msgs.GENERAL.get("b.stop_following"),
                        callback: handleRespondFollow, arg: 0 });
                }
            } else {
                // we could be following them...
                if (name.equals(us.following)) {
                    followItems.push({ label: Msgs.GENERAL.get("b.stop_following"),
                        callback: handleRespondFollow, arg: 0 });
                } else {
                    followItems.push({ label: Msgs.GENERAL.get("b.follow_other"),
                        callback: handleRespondFollow, arg: memId, enabled: !isMuted });
                }
                // and/or they could be following us...
                if (us.followers.containsKey(memId)) {
                    followItems.push({ label: Msgs.GENERAL.get("b.ditch_follower"),
                        callback: ditchFollower, arg: memId });
                } else {
                    followItems.push({ label: Msgs.GENERAL.get("b.invite_follow"),
                        callback: inviteFollow, arg: memId, enabled: !isMuted });
                }
            }
            if (followItems.length > 0) {
                followItem = { label: Msgs.GENERAL.get("l.following"), children: followItems };
            }
        }

        var icon :* = null;
        if (isUs) {
            icon = MediaWrapper.createView(
                us.memberName.getPhoto(), MediaDescSize.QUARTER_THUMBNAIL_SIZE);
//        } else if (name is VizOrthName) {
//            icon = MediaWrapper.createView(
//                VizOrthName(name).getPhoto(), MediaDesc.QUARTER_THUMBNAIL_SIZE);
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
            menuItems.push({ label: Msgs.GENERAL.get("b.open_channel"),
                        icon: Resources.WHISPER_ICON,
                        command: OPEN_CHANNEL, arg: name, enabled: !muted });
            // add as friend
            if (!onlineFriend) {
                menuItems.push({ label: Msgs.GENERAL.get("l.add_as_friend"),
                            icon: Resources.ADDFRIEND_ICON,
                            command: INVITE_FRIEND, arg: memId, enabled: !muted });
            }
            // visit
            if ((onlineFriend || isSupport)) {
                var label :String = onlineFriend ?
                    Msgs.GENERAL.get("b.visit_friend") : "Visit (as agent)";
                menuItems.push({ label: label, icon: Resources.VISIT_ICON,
                    command: VISIT_MEMBER, arg: memId, enabled: !isInOurRoom });
            }
// Visit Home disabled. Jon says it's pointless.
//            menuItems.push({ label: Msgs.GENERAL.get("b.visit_home"),
//                command: GO_MEMBER_HOME, arg: memId });
            // profile
            menuItems.push({ label: Msgs.GENERAL.get("b.view_member"),
                command: VIEW_MEMBER, arg: memId });
            // following
            if (followItem != null) {
                menuItems.push(followItem);
            }
            // partying
            if (_wctx.getPartyDirector().canInviteToParty()) {
                menuItems.push({ label: Msgs.PARTY.get("b.invite_member"),
                    command: INVITE_TO_PARTY, arg: memId,
                    enabled: !muted && !_wctx.getPartyDirector().partyContainsPlayer(memId) });
            }

            CommandMenu.addSeparator(menuItems);
            // muting
            var muted :Boolean = _mctx.getMuteDirector().isMuted(name);
            menuItems.push({ label: Msgs.GENERAL.get(muted ? "b.unmute" : "b.mute"),
                icon: Resources.BLOCK_ICON,
                callback: _mctx.getMuteDirector().setMuted, arg: [ name, !muted ] });
            // booting
            if (addWorldItems && isInOurRoom &&
                    (placeCtrl is BootablePlaceController) &&
                    BootablePlaceController(placeCtrl).canBoot()) {
                menuItems.push({ label: Msgs.GENERAL.get("b.boot"),
                    callback: handleBootFromPlace, arg: memId });
            }
            // reporting
            menuItems.push({ label: Msgs.GENERAL.get("b.complain"), icon: Resources.REPORT_ICON,
                command: COMPLAIN_MEMBER, arg: [ memId, name ] });
        }

        // now the items specific to the avatar
        if (addWorldItems && (placeCtrl is RoomObjectController)) {
            RoomObjectController(placeCtrl).addAvatarMenuItems(name, menuItems);
        }

        // login/logout
        if (isUs && !_wctx.getOrthClient().getEmbedding().hasGWT()) {
            if (_wctx.getMemberObject().isPermaguest()) {
                menuItems.push({ label: Msgs.GENERAL.get("b.logon"),
                    callback: function () :void {
                        (new LogonPanel(_wctx)).open();
                    }});
            } else {
                var creds :WorldCredentials = new WorldCredentials(null, null);
                creds.ident = "";
                menuItems.push({ label: Msgs.GENERAL.get("b.logout"),
                    command: WorldController.LOGON, arg: creds });
            }
        }
    }

    /**
     * Add pet menu items.
     */
    public function addPetMenuItems (petName :PetName, menuItems :Array) :void
    {
        const ownerMuted :Boolean = _wctx.getMuteDirector().isOwnerMuted(petName);
        if (ownerMuted) {
            menuItems.push({ label: Msgs.GENERAL.get("b.unmute_owner"), icon: BLOCK_ICON,
                callback: _mctx.getMuteDirector().setMuted,
                arg: [ new OrthName("", petName.getOwnerId()), false ] });
        } else {
            const isMuted :Boolean = _wctx.getMuteDirector().isMuted(petName);
            menuItems.push({ label: Msgs.GENERAL.get(isMuted ? "b.unmute_pet" : "b.mute_pet"),
                icon: BLOCK_ICON,
                callback: _wctx.getMuteDirector().setMuted, arg: [ petName, !isMuted ] });
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

    protected function setControlledPanel (panel :IEventDispatcher) :void
    {
        // in addition to listening for command events, let's listen
        // for LINK events and handle them all here.
        if (_controlledPanel != null) {
            _controlledPanel.removeEventListener(TextEvent.LINK, handleLink);
        }
        _idleTimer.reset();
        super.setControlledPanel(panel);
        if (_controlledPanel != null) {
            _controlledPanel.addEventListener(TextEvent.LINK, handleLink);
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
        menu.setBounds(_wctx.getTopPanel().getMainAreaBounds());
        menu.setTriggerButton(trigger);
        var r :Rectangle = trigger.getBounds(trigger.stage);
        var y :int;
        y = Math.min(r.top, _wctx.getControlBar().localToGlobal(new Point()).y);

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
     * Handles a TextEvent.LINK event.
     */
    protected function handleLink (evt :TextEvent) :void
    {
        var url :String = evt.text;
        if (StringUtil.startsWith(url, COMMAND_URL)) {
            var cmd :String = url.substring(COMMAND_URL.length);
            var sep :String = "/";
            // Sometimes we need to parse cmd args that have "/" in them, but we like using "/"
            // as our normal separator. So if the first character of the command is \uFFFC, then
            // chop that out and use \uFFFC as our separator.
            if (cmd.charAt(0) == "\uFFFC") {
                sep = "\uFFFC";
                cmd = cmd.substr(1);
            }
            var argStr :String = null;
            var slash :int = cmd.indexOf(sep);
            if (slash != -1) {
                argStr = cmd.substring(slash + 1);
                cmd = cmd.substring(0, slash);
            }
            var arg :Object = (argStr == null || argStr.indexOf(sep) == -1)
                ? argStr : argStr.split(sep);
            CommandEvent.dispatch(evt.target as IEventDispatcher, cmd, arg);

        } else {
            // A regular URL
            handleViewUrl(url);
        }
    }

    /**
     * Handles global key events.
     */
    protected function handleKeyDown (event :KeyboardEvent) :void
    {
        resetIdleTracking(event);

        switch (event.keyCode) {
        case Keyboard.F7:
            _wctx.getTopPanel().getHeaderBar().getChatTabs().selectedIndex--;
            break;
        case Keyboard.F8:
            _wctx.getTopPanel().getHeaderBar().getChatTabs().selectedIndex++;
            break;
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
        if (UberClient.isRegularClient()) {
            updateLocationDisplay();
        }
        // if we moved to a scene, set things up thusly
        var scene :Scene = _wctx.getSceneDirector().getScene();
        if (scene != null) {
            addRecentScene(scene);
        }
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
        // take care of auto-logoff regardless of whether we're "away"
        _byebyeTimer.reset();
        if (nowIdle) {
            _byebyeTimer.start();
        }

        if (nowIdle != _idle) {
            _idle = nowIdle;
            var bsvc :BodyService = _wctx.getClient().getService(BodyService) as BodyService;
            // the service may be null if we're in the studio viewer, so just don't worry about it
            if (bsvc != null) {
                bsvc.setIdle(nowIdle);
            }
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
            var focus :Object = _wctx.getStage().focus;
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
        const me :MemberObject = _wctx.getMemberObject();
        const curSceneId :int = getCurrentSceneId();

        // our groups
        var groups :Array = [];
        for each (var gm :GroupMembership in me.getSortedGroups()) {
            groups.push({ label: gm.group.toString(),
                command: GO_GROUP_HOME, arg: gm.group.getGroupId() });
        }
        if (groups.length == 0) {
            groups.push({ label: Msgs.GENERAL.get("m.no_groups"), enabled: false });
        }
        menuData.push({ label: Msgs.GENERAL.get("l.visit_groups"), children: groups });

        // our friends
        var friends :Array = [];
        for each (var fe :FriendEntry in me.getSortedFriends()) {
            friends.push({ label: fe.name.toString(),
                command: VISIT_MEMBER, arg: fe.name.getMemberId() });
        }
        if (friends.length == 0) {
            friends.push({ label: Msgs.GENERAL.get("m.no_friends"), enabled: false });
        }
        menuData.push({ label: Msgs.GENERAL.get("l.visit_friends"), children: friends });

        // recent scenes
        var sceneSubmenu :Array = [];
        for each (var entry :Object in _recentScenes) {
            sceneSubmenu.unshift({ label: StringUtil.truncate(entry.name, 50, "..."),
                command: GO_SCENE, arg: entry.id, enabled: (entry.id != curSceneId) });
        }
        if (sceneSubmenu.length == 0) {
            sceneSubmenu.push({ label: Msgs.GENERAL.get("m.none"), enabled: false });
        }
        menuData.push({ label: Msgs.WORLD.get("l.recent_scenes"), children: sceneSubmenu });

        CommandMenu.addSeparator(menuData);
        // and our home
        const ourHomeId :int = me.homeSceneId;
        if (ourHomeId != 0) {
            menuData.push({ label: Msgs.GENERAL.get("b.go_home"), command: GO_SCENE, arg: ourHomeId,
                enabled: (ourHomeId != curSceneId) });
        }
    }

    /**
     * Log off guests who have been idle for too long.
     */
    protected function checkIdleLogoff (... ignored) :void
    {
        // only do something if we're logged on and a guest
        if (_wctx.getClient().isLoggedOn() && !_wctx.isRegistered()) {
            _logoffMessage = "m.idle_logoff";
            _wctx.getClient().logoff(false);
        }
    }



    /**
     * Calls our GWT application and requests that the specified page be displayed.
     */
    protected function displayPageGWT (page :String, args :String) :Boolean
    {
        if (inGWTApp()) {
            try {
                if (ExternalInterface.available) {
                    ExternalInterface.call("displayPage", page, args);
                    return true;
                }
            } catch (e :Error) {
                log.warning("Unable to display page via Javascript", "page", page, "args", args, e);
            }
        }
        return false;
    }

    protected function addRecentScene (scene :Scene) :void
    {
        const id :int = scene.getId();

        // first, see if it's already in the list of recent scenes, and remove it if so
        for (var ii :int = _recentScenes.length - 1; ii >= 0; ii--) {
            if (_recentScenes[ii].id == id) {
                _recentScenes.splice(ii, 1);
                break;
            }
        }

        // now add it to the beginning of the list
        _recentScenes.unshift({ name: scene.getName(), id: id });

        // and make sure we're not tracking too many
        _recentScenes.length = Math.min(_recentScenes.length, MAX_RECENT_SCENES);
    }

    protected function handleBleepChange (event :NamedValueEvent) :void
    {
        if (_music == null) {
            return; // couldn't possibly concern us..
        }
        if (isMusicBleeped() == musicIsPlayingOrPaused()) {
            // just call play again with the same music, it'll handle it
            handlePlayMusic(_music);
        }
    }

    protected function handleConfigValueSet (event :NamedValueEvent) :void
    {
        // if the volume got turned up and we were not playing music, play it now.
        if ((event.name == Prefs.VOLUME) && (event.value > 0) && (_music != null) &&
               !musicIsPlayingOrPaused()) {
            handlePlayMusic(_music);
        }
    }

    protected function isMusicBleeped () :Boolean
    {
        return Prefs.isGlobalBleep() ||
            (_music != null && Prefs.isMediaBleeped(_music.audioMedia.getMediaId()));
    }

    protected function musicIsPlayingOrPaused () :Boolean
    {
        switch (_musicPlayer.getState()) {
        default: return false;
        case MediaPlayerCodes.STATE_PLAYING: // fall through
        case MediaPlayerCodes.STATE_STOPPED: // fall through
        case MediaPlayerCodes.STATE_PAUSED: return true;
        }
    }

    protected function handleMusicMetadata (event :ValueEvent) :void
    {
        if (_musicInfoShown) {
            return;
        }
        var id3 :Object = event.value;
        var artist :String = id3.artist as String;
        var songName :String = id3.songName as String;
        if (!StringUtil.isBlank(artist) || !StringUtil.isBlank(songName)) {
            if (StringUtil.isBlank(artist)) {
                artist = "unknown";
            }
            if (StringUtil.isBlank(songName)) {
                songName = "unknown";
            }
            _wctx.getNotificationDirector().notifyMusic(songName, artist);
            _musicInfoShown = true;
        }
    }

    /**
     * Sends an invitation to the specified member to follow us.
     */
    protected function inviteFollow (memId :int) :void
    {
        WorldService(_wctx.getClient().requireService(WorldService)).
            inviteToFollow(memId, _wctx.listener());
    }

    /**
     * Tells the server we no longer want someone following us. If target memberId is 0, all
     * our followers are ditched.
     */
    protected function ditchFollower (memId :int = 0) :void
    {
        WorldService(_wctx.getClient().requireService(WorldService)).
            ditchFollower(memId, _wctx.listener());
    }

    /**
     * Convenience.
     */
    protected function msvc () :MemberService
    {
        return MemberService(_wctx.getClient().requireService(MemberService));
    }

    protected function doSnapshot () :void
    {
        if (_snapPanel == null) {
            _snapPanel = new SnapshotPanel(_wctx);
            _snapPanel.addCloseCallback(function () :void {
                _snapPanel = null;
            });
        }
    }

    protected function doShowMusic (trigger :Button) :void
    {
        if (_music != null && _musicDialog == null) {
            var room :RoomObject = _wctx.getLocationDirector().getPlaceObject() as RoomObject;
            var scene :OrthScene = _wctx.getSceneDirector().getScene() as OrthScene;
            _musicDialog = new PlaylistMusicDialog(
                _wctx, trigger.localToGlobal(new Point()), room, scene);
            _musicDialog.addCloseCallback(function () :void {
                _musicDialog = null;
            });
            _musicDialog.open();
        }
    }

    protected function addFrameColorOption (menuData :Array) :void
    {
        menuData.push({ label: Msgs.GENERAL.get("b.frame_color"),
            command: doShowColorPicker });
    }

    protected function doShowColorPicker () :void
    {
        if (_picker == null) {
            _picker = new ColorPickerPanel(_wctx);
            _picker.addCloseCallback(function () :void {
                _picker = null;
            });
            _picker.open();
        }
    }

    /** Giver of life, context. */
    protected var _wctx :WorldContext;

    /** The player of music. */
    protected var _musicPlayer :Mp3AudioPlayer = new Mp3AudioPlayer();

    /** The currently playing music. */
    protected var _music :Audio;

    /** Have we displayed music info in a notification? */
    protected var _musicInfoShown :Boolean;

    protected var _musicDialog :PlaylistMusicDialog;

    protected var _snapPanel :SnapshotPanel;

    protected var _tablesPanel :TablesWaitingPanel;

    protected var _picker :ColorPickerPanel;

    /** Tracks whether we've done our first-logon movement so that we avoid trying to redo it as we
     * subsequently move between servers (and log off and on in the process). */
    protected var _didFirstLogonGo :Boolean;

    /** A scene to which to go after we logon. */
    protected var _postLogonScene :int;

    /** Set to true when we're displaying a page that has an alias, like "world-m1". */
    protected var _suppressTokenForScene :Boolean = true; // also, we suppress the first one

    /** Recently visited scenes, ordered from most-recent to least-recent */
    protected var _recentScenes :Array = [];

    /** The topmost panel in the msoy client. */
    protected var _topPanel :TopPanel;

    /** A special logoff message to use when we disconnect. */
    protected var _logoffMessage :String;

    /** Whether we think we're idle or not. */
    protected var _idle :Boolean = false;

    /** A timer to watch our idleness. */
    protected var _idleTimer :Timer;

    /** Used for idle tracking. */
    protected var _idleMousePoint :Point;

    protected var _idleStamp :Number;

    /** A timer to log us out if we've been idle too long. */
    protected var _byebyeTimer :Timer;

    /** Handlers that can perform actions and/or abort the exiting of a place. */
    protected var _placeExitHandlers :Array = [];

    /** The menus that we are currently showing. */
    protected var _currentMenus :Array = [];

    /** The URL prefix for 'command' URLs, that post CommendEvents. */
    protected static const COMMAND_URL :String = "command://";

    /** The duration after which we log off idle guests. */
    protected static const MAX_GUEST_IDLE_TIME :int = 60*60*1000;

    /** The maximum number of recent scenes we track. */
    protected static const MAX_RECENT_SCENES :int = 11;

    private static const log :Log = Log.getLog(WorldController);
}
}
