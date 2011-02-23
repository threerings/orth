//
// $Id$

package com.threerings.orth.chat.client {

import flashx.funk.ioc.inject;

import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.util.Log;

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
import com.threerings.orth.client.OrthContext;

public class OrthChatDirector extends BasicDirector
    implements MessageListener
{
    public function OrthChatDirector ()
    {
        super(inject(OrthContext));

        _chatHistory = new HistoryList();
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
        _place.getSpeakService().speak(msg, new InvocationAdapter(failure));
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
        var value :Object = event.getArgs()[0];
        if (OrthChatCodes.TELL_MSG_TYPE == event.getName()) {
            log.info("TELL()", "tell", Tell(value));

        } else if (OrthChatCodes.SPEAK_MSG_TYPE == event.getName()) {
            log.info("SPEAK()", "speak", Speak(value));
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

    protected function failure (cause :String) :void
    {
        log.error("Speak request failed", "cause", cause);
    }

    protected var _clobj :ClientObject;
    protected var _place :SpeakObject;
    protected var _chatHistory :HistoryList;

    private static const log :Log = Log.getLog(OrthChatDirector);
}
}
