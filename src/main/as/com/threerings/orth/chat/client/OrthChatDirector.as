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

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ConfirmAdapter;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.MessageListener;

import com.threerings.crowd.chat.client.ChatDisplay;
import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.chat.data.ChatMessage;
import com.threerings.crowd.chat.data.SystemMessage;
import com.threerings.crowd.chat.data.UserMessage;

import com.threerings.orth.chat.data.Broadcast;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.SpeakRouter;
import com.threerings.orth.chat.data.Tell;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.comms.client.CommsDirector;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;

public class OrthChatDirector extends BasicDirector
    implements MessageListener, TellReceiver
{
    public static function buildTellMessage (from :PlayerName, text :String) :UserMessage
    {
        return buildMessage(from, text, ChatCodes.USER_CHAT_TYPE);
    }

    public static function buildSpeakMessage (speak :Speak) :UserMessage
    {
        log.info("Building speak message", "from", speak.from, "msg", speak.message, "localType", speak.localType);
        return buildMessage(speak.from, speak.message, speak.localType);
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
        super(_octx);

        _chatHistory = new HistoryList(this);

        _ctx.getClient().getInvocationDirector().registerReceiver(new TellDecoder(this));

        _comms.commReceived.add(function (msg :Object) :void {
            if (msg is Broadcast) {
                displayFeedback(OrthCodes.GENERAL_MSGS, Broadcast(msg).message);
            }
        });
    }

    public function get placeObject () :SpeakRouter
    {
        return _place;
    }

    public function requestSendTell (tellee :PlayerName, msg :String) :UserMessage
    {
        _tellService.sendTell(tellee, msg, new ConfirmAdapter(null,
            function (cause :String) :void { log.warning("Tell failed!", "reason", cause); }));
        return buildTellMessage(_octx.myName, msg);
    }

    public function receiveTell (tell :Tell) :void
    {
        dispatchPreparedMessage(buildTellMessage(tell.from, tell.message));
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
        router.speakObject.addListener(this);
    }

    /**
     * Remove any SpeakRouter registered under the given localType.
     */
    public function deregisterRouter (type :String) :void
    {
        const oldRouter :SpeakRouter = _routers.get(type);
        if (oldRouter != null) {
            oldRouter.speakObject.removeListener(this);
        }
    }

    public function enteredLocation (place :SpeakRouter) :void
    {
        // nix our old location if we have one
        if (_place != null) {
            leftLocation(_place);
        }

        _place = place;
        place.speakObject.addListener(this);
    }

    public function leftLocation (place :SpeakRouter) :void
    {
        // if this is our current place chat, then stop listening to it
        if (place == _place) {
            _place.speakObject.removeListener(this);
            _place = null;
        }
    }

    public function displayFeedback (bundle :String, msg :String) :void
    {
        const msgBundle :MessageBundle = _msgMgr.getBundle(bundle);
        dispatchPreparedMessage(new SystemMessage(
            msgBundle.xlate(msg), bundle, SystemMessage.FEEDBACK));
    }

    protected const _msgMgr :MessageManager = inject(MessageManager);

    // from MessageListener
    public function messageReceived (event :MessageEvent) :void
    {

        // ORTH TODO: for now, we have our own Tell and Speak objects from our rewrite,
        // but the ChatMessage-based approach of the rendering code (from Whirled). When
        // I did my from-scratch rewrite I wanted to be clear about not using any of the
        // crowd stuff, and I still think that is cleaner, but then again it's perhaps a
        // little silly to create near-exact duplicates of lots of useful data classes.
        // We should decide to go one way or another rather than "convert" here.
        var value :Object = event.getArgs()[0];
        if (OrthChatCodes.SPEAK_MSG_TYPE == event.getName()) {
            dispatchPreparedMessage(buildSpeakMessage(Speak(value)));

        } else {
            log.warning("Got unhandled message type", "eventName", event.getName(), "event", event);
            return;
        }
    }

    // from BasicDirector
    override protected function clientObjectUpdated (client :Client) :void
    {
        // we have an aether client object; listen to it for tells
        _clobj = _ctx.getClient().getClientObject();
        _clobj.addListener(this);
    }

    // from BasicDirector
    override public function clientDidLogoff (event :ClientEvent) :void
    {
        // i don't see this happening often, but can't hurt to be proper
        if (_clobj != null) {
            _clobj.removeListener(this);
        }
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
        _tellService = TellService(_ctx.getClient().requireService(TellService));
    }

    protected var _clobj :ClientObject;
    protected var _place :SpeakRouter;
    protected var _chatHistory :HistoryList;
    protected var _tellService :TellService;

    protected const _routers :Map = Maps.newMapOf(String);

    /** A list of registered chat displays. */
    protected var _displays :ObserverList = new ObserverList();

    protected const _comms :CommsDirector = inject(CommsDirector);
    protected const _octx :OrthContext = inject(OrthContext);

    private static const log :Log = Log.getLog(OrthChatDirector);
}
}
