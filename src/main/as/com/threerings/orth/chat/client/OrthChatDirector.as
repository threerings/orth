//
// $Id$

package com.threerings.orth.chat.client {

import flashx.funk.ioc.inject;

import com.threerings.crowd.chat.client.ChatDisplay;
import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.crowd.chat.data.ChatMessage;
import com.threerings.crowd.chat.data.UserMessage;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.MessageManager;
import com.threerings.util.ObserverList;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.InvocationAdapter;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.MessageListener;

import com.threerings.orth.chat.client.HistoryList;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.SpeakObject;
import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.Tell;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthContext;

public class OrthChatDirector extends BasicDirector
    implements MessageListener
{
    public function OrthChatDirector ()
    {
        super(inject(OrthContext));

        _chatHistory = new HistoryList(this);
    }

    /** Some code somewhere (e.g. a chat input control) wants us to speak in our room. */
    public function requestPlaceSpeak (msg :String) :void
    {
        // if we're nowhere, ignore silently
        if (_place == null) {
            log.warning("Eek! We're nowhere and we're trying to speak!");
            return;
        }

        // else invoke
        _place.getSpeakService().speak(msg, new InvocationAdapter(function (cause :String) :void {
            log.error("Speak request failed", "cause", cause);
        }));

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

    public function enteredLocation (place :SpeakObject) :void
    {
        // nix our old location if we have one
        if (_place != null) {
            leftLocation(_place);
        }

        _place = place;
        place.asDObject().addListener(this);
    }

    public function leftLocation (place :SpeakObject) :void
    {
        // if this is our current place chat, then stop listening to it
        if (place == _place) {
            _place.asDObject().removeListener(this);
            _place = null;
        }
    }

    // from MessageListener
    public function messageReceived (event :MessageEvent) :void
    {
        var msg :UserMessage = new UserMessage();

        // ORTH TODO: for now, we have our own Tell and Speak objects from our rewrite,
        // but the ChatMessage-based approach of the rendering code (from Whirled). When
        // I did my from-scratch rewrite I wanted to be clear about not using any of the
        // crowd stuff, and I still think that is cleaner, but then again it's perhaps a
        // little silly to create near-exact duplicates of lots of useful data classes.
        // We should decide to go one way or another rather than "convert" here.
        var value :Object = event.getArgs()[0];
        if (OrthChatCodes.TELL_MSG_TYPE == event.getName()) {
            var tell :Tell = Tell(value);
            msg.speaker = tell.from;
            msg.mode = ChatCodes.DEFAULT_MODE;
            msg.setClientInfo(Msgs.CHAT.xlate(tell.message), ChatCodes.USER_CHAT_TYPE);

        } else if (OrthChatCodes.SPEAK_MSG_TYPE == event.getName()) {
            var speak :Speak = Speak(value);
            msg.speaker = speak.from;
            msg.mode = ChatCodes.DEFAULT_MODE;
            msg.setClientInfo(Msgs.CHAT.xlate(speak.message), ChatCodes.PLACE_CHAT_TYPE);
        }

        dispatchPreparedMessage(msg);
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

    protected var _clobj :ClientObject;
    protected var _place :SpeakObject;
    protected var _chatHistory :HistoryList;

    /** A list of registered chat displays. */
    protected var _displays :ObserverList = new ObserverList();

    protected const _msgMgr :MessageManager = inject(MessageManager);

    private static const log :Log = Log.getLog(OrthChatDirector);
}
}
