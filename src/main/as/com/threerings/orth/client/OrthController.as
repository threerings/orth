//
// $Id: MsoyController.as 19431 2010-10-22 22:08:36Z zell $

package com.threerings.orth.client {

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.events.TimerEvent;

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.external.ExternalInterface;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.ui.Keyboard;
import flash.utils.Timer;
import flash.utils.getTimer;

import mx.controls.Button;
import mx.controls.Menu;
import mx.core.IUITextField;
import mx.events.MenuEvent;

import com.threerings.util.ArrayUtil;
import com.threerings.util.CommandEvent;
import com.threerings.util.Controller;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.NetUtil;
import com.threerings.util.StringUtil;

import com.threerings.presents.net.Credentials;

import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.client.BodyService;
import com.threerings.crowd.client.LocationAdapter;
import com.threerings.crowd.data.CrowdCodes;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.flex.ChatControl;
import com.threerings.flex.CommandButton;
import com.threerings.flex.CommandMenu;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ClientObserver;
import com.threerings.presents.client.LogonError;

import com.threerings.crowd.chat.client.ChatCantStealFocus;

import com.threerings.msoy.data.MsoyCodes;
import com.threerings.msoy.data.PlaceInfo;
import com.threerings.orth.data.MediaDesc;
import com.threerings.msoy.data.all.MemberName;

import com.threerings.msoy.room.data.PuppetName;

import com.threerings.msoy.item.data.all.Item;
import com.threerings.msoy.item.data.all.ItemIdent;

public class OrthController extends Controller
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

    /** Command to display the go menu. */
    public static const POP_GO_MENU :String = "PopGoMenu";

    /** Command to display a simplified menu for muting/etc a member. */
    public static const POP_MEMBER_MENU :String = "PopMemberMenu";

    /** Command to display a simplified menu for muting/etc a pet. */
    // nada here. Pets only exist in world, but we handle them generically
    public static const POP_PET_MENU :String = "PopPetMenu";

    /** Command to display sign-up info for guests. */
    public static const SHOW_SIGN_UP :String = "ShowSignUp";

    /** Command to show an (external) URL. */
    public static const VIEW_URL :String = "ViewUrl";

    /** Command to view an item, arg is an ItemIdent. */
    public static const VIEW_ITEM :String = "ViewItem";

    /** Command to flag an item, arg is an ItemIdent. */
    public static const FLAG_ITEM :String = "FlagItem";

    /** Command to view all games */
    public static const VIEW_GAMES :String = "ViewGames";

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

    /** Command to tweet an message. */
    public static const TWEET :String = "Tweet";

    /** Command to tweet an invite to a specific game. */
    public static const TWEET_GAME :String = "TweetGame";

    /** Command to show users the subscribe page. */
    public static const SUBSCRIBE :String = "Subscribe";

    // NOTE:
    // Any commands defined in this class should be handled in this class.
    // Currently, this is not the case. Some commands are here without even an abstract or
    // empty method to handle them. Traditionally this would be bad, but since we currently
    // only have one subclass implementation, we're just going to take a shortcut and say
    // that any command defined but not handled here is "abstract". The command dispatch
    // system will log an error whenever a command is unhandled, so it should not be too hard
    // for someone to track down the issue. However, once we have subclasses other than
    // WorldController, we will want to ensure that only commands that are global are here
    // and probably also that we at least define an abstract (as best we can in actionscript)
    // method to handle the command, so that it's easier for people to see what they need
    // to implement in the subclasses.
    //

    /**
     * Creates and initializes the controller.
     */
    public function MsoyController (mctx :MsoyContext, topPanel :TopPanel)
    {
        _mctx = mctx;
        _mctx.getClient().addServiceGroup(CrowdCodes.CROWD_GROUP);
        _mctx.getClient().addClientObserver(this);
        _topPanel = topPanel;

        // create a timer to poll mouse position and track timing
        _idleTimer = new Timer(1000);
        _idleTimer.addEventListener(TimerEvent.TIMER, handlePollIdleMouse);

        // create a timer that checks whether we should be logged out for being idle too long
        _byebyeTimer = new Timer(MAX_GUEST_IDLE_TIME, 1);
        _byebyeTimer.addEventListener(TimerEvent.TIMER, checkIdleLogoff);

        // listen for location changes
        _mctx.getLocationDirector().addLocationObserver(
            new LocationAdapter(null, this.locationDidChange, null));

        var stage :Stage = mctx.getStage();
        setControlledPanel(topPanel.systemManager);
//        stage.addEventListener(FocusEvent.FOCUS_OUT, handleUnfocus);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, handleStageKeyDown, false, int.MAX_VALUE);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, int.MAX_VALUE);
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
        if (NetUtil.navigateToURL(url, windowOrTab)) {
            return true;

        } else {
            _mctx.displayFeedback(
                MsoyCodes.GENERAL_MSGS, MessageBundle.tcompose("e.no_navigate", url));

            // TODO
            // experimental: display a popup with the URL (this could be moved to handleLink()
            // if this method is altered to return a success Boolean
            new MissedURLDialog(_mctx, url);
            return false;
        }
    }

    /**
     * Creates a link to a page at www.whirled.com that we will be sharing (not following
     * ourselves). This will have appropriate affiliate information included. If the friend
     * parameter is set, a friend request will be sent to the affiliate on behalf of the follower
     * when the follower registers.
     */
    public function createSharableLink (page :String, friend :Boolean) :String
    {
        var servlet :String = friend ? "friend" : "welcome";
        return DeploymentConfig.serverURL + servlet + "/" + _mctx.getMyId() + "/" + page;
    }

    /**
     * Returns information about the place or places the user is currently in.
     */
    public function getPlaceInfo () :PlaceInfo
    {
        return new PlaceInfo();
    }

    /**
     * Can we "manage" the current place.
     */
    public function canManagePlace () :Boolean
    {
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
    public function handlePopMemberMenu (name :String, memberId :int, puppet :Boolean = false) :void
    {
        var menuItems :Array = [];
        // reconstitute the memberName from args
        var memName :MemberName = puppet ? new PuppetName(name, memberId)
                                         : new MemberName(name, memberId);
        addMemberMenuItems(memName, menuItems);
        CommandMenu.createMenu(menuItems, _mctx.getTopPanel()).popUpAtMouse();
    }

    /**
     * Handles the ABOUT command.
     */
    public function handleAbout () :void
    {
        new AboutDialog(_mctx);
    }

    /**
     * Handles the CLOSE_PLACE_VIEW command.
     */
    public function handleClosePlaceView () :void
    {
        // handled by our derived classes
    }

    /**
     * Handles the VIEW_GAMES command.
     */
    public function handleViewGames () :void
    {
        // handled by our derived classes
    }

    /**
     * Handles the MOVE_BACK command.
     */
    public function handleMoveBack (closeInsteadOfHome :Boolean = false) :void
    {
        // handled by our derived classes
    }

    /**
     * Handles the POP_SHARE_DIALOG command.
     */
    public function handlePopShareDialog () :void
    {
        // do it this way so that we don't mess up the dialog popper.
        if (!_mctx.getControlBar().shareBtn.selected) {
            _mctx.getControlBar().shareBtn.activate();
        }
    }

    /**
     * Can we move back?
     */
    public function canMoveBack () :Boolean
    {
        return false;
    }

    /**
     * Handles the SET_DISPLAY_STATE command.
     */
    public function handleSetDisplayState (state :String = null) :void
    {
        const stage :Stage = _mctx.getStage();
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
            _mctx.getControlBar().fullBtn.enabled = false;
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
        // give the client a chance to log off, then log back on
        _topPanel.callLater(function () :void {
            var client :Client = _mctx.getClient();
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
        new ChatPrefsDialog(_mctx);
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
            command: MsoyController.VIEW_ITEM, arg: ident });
        if (_mctx.isRegistered()) {
            menuItems.push({ label: Msgs.GENERAL.get("b.flag_item", kind),
                command: MsoyController.FLAG_ITEM, arg: ident });
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
     * Handles TWEET
     */
    public function handleTweet (msg :String) :void
    {
        handleViewUrl("http://twitter.com/home?status=" + encodeURIComponent(msg), "_blank");
    }

    /**
     * Handles TWEET_GAME
     */
    public function handleTweetGame (gameId :int, gameName :String, party :Boolean = true) :void
    {
        var shareLink :String = createSharableLink(
            "world-game_i_" + gameId + "_" + _mctx.getMyId(), true);
        var tweet :String = Msgs.GAME.get("m.invite_twitter" + (party ? "_party" : ""),
            gameName, shareLink);
        handleTweet(tweet);
    }

    /**
     * Updates our header and control bars based on our current location. This is called
     * automatically when the world location changes but must be called explicitly by the game
     * services when we enter a game as the world services don't know about that.
     */
    public function updateLocationDisplay () :void
    {
        _mctx.getUpsellDirector().locationUpdated();

//        if (_goMenu != null) {
//            _goMenu.hide();
//            // will be nulled automatically...
//        }
    }

    /**
     * Requests that standard menu items be added to the supplied menu which is being popped up as
     * a result of clicking on another player (their name, or their avatar) somewhere in Whirled.
     */
    public function addMemberMenuItems (
        member :MemberName, menuItems :Array, addWorldItems :Boolean = true) :void
    {
        // nothing by default
    }

    /**
     * Attempts to reconnect to the server and return to our starting location.
     */
    public function reconnectClient () :void
    {
        if (_mctx.getMsoyClient().getEmbedding().hasGWT() && ExternalInterface.available) {
            ExternalInterface.call("rebootFlashClient");
        } else {
            _mctx.getClient().logon();
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
        // nada
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
                _mctx.getClient(), _logoffMessage, reconnectClient));
            _logoffMessage = null;
        } else {
            _topPanel.setPlaceView(new BlankPlaceView(_mctx));
        }
    }

    // from ClientObserver
    public function clientFailedToLogon (event :ClientEvent) :void
    {
        _topPanel.setPlaceView(new DisconnectedPanel(
            _mctx.getClient(), event.getCause().message, reconnectClient));
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
     * Return true if we are running in the GWT application shell, false otherwise.
     */
    protected function inGWTApp () :Boolean
    {
        var pt :String = Capabilities.playerType;
        if (pt == "StandAlone" || pt == "External") {
            return false;
        }
        if (!_mctx.getMsoyClient().getEmbedding().hasGWT()) {
            return false;
        }
        return true;
    }

    override protected function setControlledPanel (panel :IEventDispatcher) :void
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
        menu.setBounds(_mctx.getTopPanel().getMainAreaBounds());
        menu.setTriggerButton(trigger);
        var r :Rectangle = trigger.getBounds(trigger.stage);
        var y :int;
        y = Math.min(r.top, _mctx.getControlBar().localToGlobal(new Point()).y);

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
            _mctx.getTopPanel().getHeaderBar().getChatTabs().selectedIndex--;
            break;
        case Keyboard.F8:
            _mctx.getTopPanel().getHeaderBar().getChatTabs().selectedIndex++;
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
            var bsvc :BodyService = _mctx.getClient().getService(BodyService) as BodyService;
            // the service may be null if we're in the studio viewer, so just don't worry about it
            if (bsvc != null) {
                bsvc.setIdle(nowIdle);
            }
        }
    }

//    /**
//     * Detect the kind of unfocus that happens when the user switches tabs.
//     */
//    protected function handleUnfocus (event :FocusEvent) :void
//    {
//        if (event.target is TextField && event.relatedObject == null) {
//            _mctx.getStage().addEventListener(MouseEvent.MOUSE_MOVE, handleRefocus);
//        }
//    }
//
//    /**
//     * Attempt to refocus the chatbox after the browser caused focus to lose.
//     */
//    protected function handleRefocus (event :MouseEvent) :void
//    {
//        _mctx.getStage().removeEventListener(MouseEvent.MOUSE_MOVE, handleRefocus);
//        checkChatFocus();
//    }

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
            var focus :Object = _mctx.getStage().focus;
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
        // see subclass
    }

    /**
     * Log off guests who have been idle for too long.
     */
    protected function checkIdleLogoff (... ignored) :void
    {
        // only do something if we're logged on and a guest
        if (_mctx.getClient().isLoggedOn() && !_mctx.isRegistered()) {
            _logoffMessage = "m.idle_logoff";
            _mctx.getClient().logoff(false);
        }
    }

    /** Provides access to client-side directors and services. */
    protected var _mctx :MsoyContext;

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

    private static const log :Log = Log.getLog(MsoyController);
}
}
