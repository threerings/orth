//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.client {
import flashx.funk.ioc.inject;

import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.MessageBundle;
import com.threerings.util.MessageManager;
import com.threerings.util.ObserverList;

import com.threerings.presents.client.Client;

import com.threerings.crowd.chat.client.ChatDisplay;
import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.chat.data.ChatMessage;
import com.threerings.crowd.chat.data.SystemMessage;
import com.threerings.crowd.chat.data.UserMessage;

import com.threerings.orth.aether.client.AetherDirectorBase;
import com.threerings.orth.chat.data.Broadcast;
import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.SpeakPlace;
import com.threerings.orth.chat.data.SpeakRouter;
import com.threerings.orth.chat.data.Tell;
import com.threerings.orth.client.Listeners;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.comms.client.CommsDirector;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;

public class OrthChatDirector extends AetherDirectorBase
    implements TellReceiver
{
    public static function buildTellMessage (from :PlayerName, text :String) :UserMessage
    {
        return buildMessage(from, MessageBundle.taint(text), ChatCodes.USER_CHAT_TYPE);
    }

    public static function buildSpeakMessage (speak :Speak) :UserMessage
    {
        return buildMessage(speak.from, MessageBundle.taint(speak.message), speak.localType);
    }

    public static function buildMessage (from :PlayerName, text :String, type :String) :UserMessage
    {
        var msg :UserMessage = new UserMessage();
        msg.speaker = from;
        msg.mode = ChatCodes.DEFAULT_MODE;
        msg.setClientInfo(Msgs.CHAT.xlate(text), type);
        return msg;
    }

    public function OrthChatDirector ()
    {
        _chatHistory = new HistoryList(this);

        _client.getInvocationDirector().registerReceiver(new TellDecoder(this));

        _comms.commReceived.add(function (msg :Object) :void {
            if (msg is Broadcast) {
                displayFeedback(OrthCodes.GENERAL_MSGS, Broadcast(msg).message);
            } else if (msg is Speak) {
                receiveSpeak(Speak(msg));
            }
        });
    }

    public function get placeObject () :SpeakRouter
    {
        return _placeRouter;
    }

    public function requestSendTell (tellee :PlayerName, msg :String) :UserMessage
    {
        _tellService.sendTell(tellee, msg, Listeners.confirmListener(OrthCodes.CHAT_MSGS));
        return buildTellMessage(aetherObj.playerName, msg);
    }

    public function receiveTell (tell :Tell) :void
    {
        dispatchPreparedMessage(buildTellMessage(tell.from, tell.message));
    }

    public function receiveSpeak (speak :Speak) :void
    {
        // filter out any speaks from ignored players
        if (!aetherObj.ignored.containsKey(speak.from.id)) {
            dispatchPreparedMessage(buildSpeakMessage(speak));
        }
    }

    public function getHistoryList () :HistoryList
    {
        return _chatHistory;
    }

    /** This can be made to do something real if we implement tabbed chatting. */
    public function getCurrentLocalType () :String
    {
        return ChatCodes.PLACE_CHAT_TYPE;
    }

    /**
     * Adds the supplied chat display to the front of the chat display list. It will subsequently
     * be notified of incoming chat messages as well as tell responses.
     */
    public function pushChatDisplay (display :ChatDisplay) :void
    {
        _displays.add(display, 0);
    }

    /**
     * Adds the supplied chat display to the chat display list. It will subsequently be notified of
     * incoming chat messages as well as tell responses.
     */
    public function addChatDisplay (display :ChatDisplay) :void
    {
        _displays.add(display);
    }

    /**
     * Removes the specified chat display from the chat display list. The display will no longer
     * receive chat related notifications.
     */
    public function removeChatDisplay (display :ChatDisplay) :void
    {
        _displays.remove(display);
    }

    /**
     * Requests that all chat displays clear their contents.
     */
    public function clearDisplays () :void
    {
        _displays.apply(function (disp :ChatDisplay) :void {
            disp.clear();
        });
    }

    /**
     * Add a new SpeakRouter under the given localType.
     */
    public function registerRouter (type :String, router :SpeakRouter) :void
    {
        // stop listening to the old one, if there was one
        deregisterRouter(type);

        // start listening to the new one
        _routers.put(type, router);
        router.startRouting();
    }

    /**
     * Remove any SpeakRouter registered under the given localType.
     */
    public function deregisterRouter (type :String) :void
    {
        const oldRouter :SpeakRouter = _routers.get(type);
        if (oldRouter != null) {
            oldRouter.stopRouting();
        }
    }

    public function enteredLocation (place :SpeakPlace) :void
    {
        // nix our old location if we have one
        if (_placeRouter != null) {
            _placeRouter.stopRouting();
        }

        _module.inject(function () :void {
            _placeRouter = new DObjectSpeakRouter(place.getDObject(), place.getSpeakService());
        });
        _placeRouter.startRouting();
    }

    public function leftLocation (place :SpeakPlace) :void
    {
        // if this is our current place chat, then stop listening to it
        if (_placeRouter != null && _placeRouter.dobj == place) {
            _placeRouter.stopRouting();
            _placeRouter = null;
        }
    }

    public function displayFeedback (bundle :String, msg :String) :void
    {
        const msgBundle :MessageBundle = _msgMgr.getBundle(bundle);
        dispatchPreparedMessage(new SystemMessage(
            msgBundle.xlate(msg), bundle, SystemMessage.FEEDBACK));
    }

    protected function dispatchPreparedMessage (message :ChatMessage) :void
    {
        _displays.apply(function (disp :ChatDisplay) :void {
            disp.displayMessage(message);
        });
    }

    override protected function registerServices (client :Client) :void
    {
        client.addServiceGroup(OrthCodes.AETHER_GROUP);
    }

    override protected function fetchServices (client :Client) :void
    {
        _tellService = TellService(_client.requireService(TellService));
    }

    protected var _placeRouter :DObjectSpeakRouter;
    protected var _chatHistory :HistoryList;
    protected var _tellService :TellService;

    protected const _routers :Map = Maps.newMapOf(String);

    /** A list of registered chat displays. */
    protected var _displays :ObserverList = new ObserverList();

    protected const _comms :CommsDirector = inject(CommsDirector);
    protected const _msgMgr :MessageManager = inject(MessageManager);

    private static const log :Log = Log.getLog(OrthChatDirector);
}
}
