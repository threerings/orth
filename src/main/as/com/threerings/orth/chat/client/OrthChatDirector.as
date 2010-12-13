//
// $Id: MsoyChatDirector.as 19656 2010-11-29 04:36:17Z zell $

package com.threerings.orth.chat.client {
import com.threerings.msoy.chat.client.*;
import com.threerings.orth.chat.data.OrthChatChannel;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.ChannelName;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.room.data.RoomName;

import flash.utils.getTimer; // function

import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.Name;
import com.threerings.util.Throttle;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.InvocationAdapter;
import com.threerings.presents.client.ResultAdapter;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.chat.client.ChannelSpeakService;
import com.threerings.crowd.chat.client.SpeakService;
import com.threerings.crowd.chat.data.ChannelSpeakMarshaller;
import com.threerings.crowd.chat.data.ChatChannel;
import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.chat.data.ChatMessage;
import com.threerings.crowd.chat.data.SystemMessage;
import com.threerings.crowd.chat.data.TellFeedbackMessage;
import com.threerings.crowd.chat.data.UserMessage;

import com.whirled.ui.PlayerList;

import com.threerings.msoy.client.DeploymentConfig;
import com.threerings.msoy.client.Msgs;
import com.threerings.msoy.client.MsoyContext;
import com.threerings.msoy.data.MemberObject;
import com.threerings.msoy.data.MsoyCodes;
import com.threerings.msoy.data.PrimaryPlace;
import com.threerings.msoy.data.all.ChannelName;
import com.threerings.msoy.data.all.GroupName;
import com.threerings.msoy.data.all.JabberName;
import com.threerings.msoy.data.all.MemberName;
import com.threerings.msoy.data.all.RoomName;

import com.threerings.msoy.chat.data.MsoyChatChannel;
import com.threerings.msoy.chat.data.JabberMarshaller;
import com.threerings.msoy.chat.client.JabberService;

import com.threerings.msoy.room.data.RoomObject;

/**
 * Handles the dispatching of chat messages based on their "channel" (room/game, individual, or
 * actual custom channel). Manages chat history tracking for same.
 */
public class OrthChatDirector extends ChatDirector
{
    /** The maximum size of any utterance. */
    public static const MAX_CHAT_LENGTH :int = 200;

    // statically reference classes we require
    ChannelSpeakMarshaller;

    public function OrthChatDirector (ctx :OrthContext)
    {
        super(ctx, ctx.getMessageManager(), OrthCodes.CHAT_MSGS);
        _mctx = ctx;

        registerCommandHandler(Msgs.CHAT, "away", new AwayHandler());
        registerCommandHandler(Msgs.CHAT, "bleepall", new BleepAllHandler());

        // override the broadcast command from ChatDirector
        registerCommandHandler(Msgs.CHAT, "broadcast", new OrthBroadcastHandler());

        // Ye Olde Easter Eggs
        registerCommandHandler(Msgs.CHAT, "~egg", new HackHandler(function (args :String) :void {
            _handlers.remove("~egg");
            _mctx.getControlBar().setFullOn();
            SubtitleGlyph.thumbsEnabled = true;
            displayFeedback(null, MessageBundle.taint("Easter eggs enabled:\n" +
                " * Full-screen button (no chat, due to flash security).\n" +
                " * Chat link hover pics.\n" +
                "\n" +
                "These experimental features may be removed in the future. Let us know if you " +
                "find them incredibly useful."));
        }));

        registerCommandHandler(Msgs.CHAT, "wipe", new WipeHandler());

        addChatDisplay(_chatHistory = new HistoryList(this));

        // create our room occupant list
        _roomOccList = new RoomOccupantList(_mctx);
    }

    /**
     * Whoever creates the chat tab bar is responsible for setting it here, so that we can properly
     * handle chat channels.
     */
    public function setChatTabs (tabs :ChatTabBar) :void
    {
        _chatTabs = tabs;
        addChatDisplay(_chatTabs);
    }

    /**
     * Get the currently-selected chat channel, or null if none.
     */
    public function getCurrentChannel () :OrthChatChannel
    {
        return _chatTabs.getCurrentChannel();
    }

    /**
     * Get the localType of the currently-selected tab.
     */
    public function getCurrentLocalType () :String
    {
        var channel :OrthChatChannel = getCurrentChannel();
        return (channel == null) ? ChatCodes.PLACE_CHAT_TYPE : channel.toLocalType();
    }

    /**
     * Our parent's clearDisplays() method will only clear the current channel.
     */
    public function clearAllDisplays () :void
    {
        _chatHistory.clearAll();
        clearDisplays();
    }

    /**
     * Retrieve the global chat history that contains every message received on this client,
     * within a history list size limit.
     */
    public function getHistoryList () :HistoryList
    {
        return _chatHistory;
    }

    /**
     * Return true if we've already got a chat channel open with the specified Name.
     */
    public function hasOpenChannel (name :Name) :Boolean
    {
        return _chatTabs.containsTab(makeChannel(name));
    }

    /**
     * Opens the chat interface for the supplied player, group or private chat channel, selecting
     * the appropriate tab if said channel is already open.
     *
     * @param name either a OrthName, GroupName, ChannelName or RoomName.
     */
    public function openChannel (name :Name) :void
    {
        _chatTabs.openChannelTab(makeChannel(name), true);
    }

    /**
     * Returns a list containing the chat participants for the specified local type.
     */
    public function getPlayerList (ltype :String) :PlayerList
    {
        if (ltype != ChatCodes.PLACE_CHAT_TYPE) {
            return null;
        }
        if (_roomOccList.havePlace()) {
            return _roomOccList;
        }
        return _gamePlayerList;
    }

    override public function clientDidLogon (event :ClientEvent) :void
    {
        super.clientDidLogon(event);
        _chatTabs.memberObjectUpdated(_mctx.getMemberObject());
    }

    // from ChatDirector
    override public function requestSpeak (
        speakSvc :SpeakService, message :String, mode :int) :void
    {
        var channel :OrthChatChannel = getCurrentChannel();
        if ((speakSvc != null) || // if a specific service is specified, OR
                (channel == null) || (channel.type == OrthChatChannel.ROOM_CHANNEL)) {
                // ...if place chat, then we don't need to do anything special.
            super.requestSpeak(speakSvc, message, mode);
            return;
        }
        if (channel.type == OrthChatChannel.MEMBER_CHANNEL) {
            // route this to requestTell, which will filter
            requestTell(channel.ident as Name, message, null, channel.toLocalType());
            return;
        }

        // ABOVE this line is stuff handled in the base class, that filters properly
        // BELOW this line, we need to filter it ourselves
        message = filter(message, null, true);
        if (message == null) {
            // they filtered it into nothingness!
            return;
        }

        requestChannelSpeak(channel, message, mode);
    }

    override public function displayFeedback (bundle :String, message :String) :void
    {
        // alter things so that we deliver feedback on the open tab
        displaySystem(bundle, message, SystemMessage.FEEDBACK, getCurrentLocalType());
    }

    // from ChatDirector
    override public function enteredLocation (place :PlaceObject) :void
    {
        if (!(place is PrimaryPlace)) {
            // If it's a non-primary place, only add it as an auxiliary source, just to be sure.
            // TODO: figure out a sensible localtype for non-primary places (presently, only AVRGs)
            addAuxiliarySource(place, "orthAux");
            return; // block non-primary places from super
        }

        super.enteredLocation(place);

        // let our occupant list know about our new location
        if (place is RoomObject) {
            _roomOccList.setPlaceObject(place);
        }
        _chatTabs.setPlaceName(PrimaryPlace(place).getName());
    }

    // from ChatDirector
    override public function leftLocation (place :PlaceObject) :void
    {
        if (!(place is PrimaryPlace)) {
            // See notes in enteredLocation
            removeAuxiliarySource(place);
            return;
        }

        // only change the name if it's the place we're actually tracking
        if (place == _place) {
            // let our occupant list know that we're nowhere
            _roomOccList.setPlaceObject(null);
            _chatTabs.setPlaceName(null);
        }

        super.leftLocation(place);
    }

    /**
     * Sets the player list for a game that has just started up.
     */
    public function setGamePlayerList (plobj :PlaceObject, list :PlayerList) :void
    {
        _gamePlace = plobj;
        _gamePlayerList = list;
    }

    /**
     * Clears the player list for a game that has just shut down.
     */
    public function clearGamePlayerList (plobj :PlaceObject) :void
    {
        if (_gamePlace != plobj) {
            log.warning("Clearing game player list for a different place?",
                        "plobj", plobj, "gameplace", _gamePlace);
            return;
        }
        _gamePlace = null;
        _gamePlayerList = null;
    }

    // from ChatDirector
    override protected function setClientInfo (msg :ChatMessage, localType :String) :void
    {
        if ((msg.localtype == null) && ( // skip this if msg.localtype is already set
                (msg is UserMessage && localType == ChatCodes.USER_CHAT_TYPE) ||
                (msg is TellFeedbackMessage))) {
            // use a more specific localtype
            var member :OrthName = (msg as UserMessage).getSpeakerDisplayName() as OrthName;
            localType = OrthChatChannel.makeMemberChannel(member).toLocalType();
        }
        super.setClientInfo(msg, localType);
    }

    // from ChatDirector
    override protected function getChannelLocalType (channel :ChatChannel) :String
    {
        var mchannel :OrthChatChannel = (channel as OrthChatChannel);
        // this is called by the ChatDirector when a message arrives, we sneak in here and make
        // sure we have a chat channel tab available for this channel type so that when the chat
        // director goes to dispatch the message, we're all ready to go; if the tab already exists,
        // openChannelTab basically NOOPs
        _chatTabs.openChannelTab(mchannel, false);
        return mchannel.toLocalType();
    }

    // from ChatDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);
        _csservice = (client.requireService(ChannelSpeakService) as ChannelSpeakService);
        _jservice = (client.requireService(JabberService) as JabberService);
    }

    // from ChatDirector
    override protected function suppressTooManyCaps () :Boolean
    {
        return false;
    }

    // from ChatDirector
    override protected function clearChatOnClientExit () :Boolean
    {
        return false; // TODO: we need this because on orth we "exit" when change servers
    }

    // from ChatDirector
    override protected function checkCanChat (
        speakSvc :SpeakService, message :String, mode :int) :String
    {
        var now :int = getTimer();
        if (_throttle.throttleOpAt(now)) {
            return "e.chat_throttled";
        }
        // if we allow it, we might also count this message as more than one "op"
        if (message.length > 8) {
            _throttle.noteOp(now);
        }
        if (message.length > (MAX_CHAT_LENGTH / 2)) {
            _throttle.noteOp(now);
        }
        return null;
    }

    /**
     * Requests that a message be delivered to the specified channel.
     */
    protected function requestChannelSpeak (channel :OrthChatChannel, msg :String, mode :int) :void
    {
        _csservice.speak(channel, msg, mode);
    }

    /**
     * Create a ChatChannel object for the specified Name.
     */
    protected function makeChannel (name :Name) :OrthChatChannel
    {
        if (name is OrthName) {
            return OrthChatChannel.makeMemberChannel(name as OrthName);
        } else if (name is ChannelName) {
            return OrthChatChannel.makePrivateChannel(name as ChannelName);
        } else if (name is RoomName) {
            return OrthChatChannel.makeRoomChannel(name as RoomName);
        } else {
            Log.getLog(this).warning("Requested to create unknown type of channel",
                "name", name, "type", ClassUtil.getClassName(name));
            return null;
        }
    }

    /** Casted form of our context. */
    protected var _mctx :OrthContext;

    /** You may utter 8 things per 5 seconds, but large things count as two. */
    protected var _throttle :Throttle = new Throttle(8, 5000);

    protected var _chatTabs :ChatTabBar;
    protected var _chatHistory :HistoryList;
    protected var _roomOccList :RoomOccupantList;

    protected var _gamePlayerList :PlayerList;
    protected var _gamePlace :PlaceObject;

    protected var _csservice :ChannelSpeakService;
    protected var _jservice :JabberService;
}
}
