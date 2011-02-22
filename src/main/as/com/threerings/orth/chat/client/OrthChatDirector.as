//
// $Id$

package com.threerings.orth.chat.client {

import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.InvocationAdapter;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.MessageListener;

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
    }

    /** Some code somewhere (e.g. a chat input control) wants us to speak in our room. */
    public function requestPlaceSpeak (msg :String) :void
    {
        // if we're nowhere, ignore silently
        if (_place == null) {
            return;
        }

        // else invoke
        _place.getSpeakService().speak(msg, new InvocationAdapter(failure));
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

    protected function failure (cause :String) :void
    {
        log.error("Speak request failed", "cause", cause);
    }

    protected var _place :SpeakObject;

    private static const log :Log = Log.getLog(OrthChatDirector);
}
}
