//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.client
{
import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.MessageListener;

import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.chat.data.SpeakRouter;

/**
 * Implement SpeakRouter using DObject broadcast messages.
 */
public class DObjectSpeakRouter
    implements MessageListener, SpeakRouter
{
    public function DObjectSpeakRouter (dobj :DObject, svc :SpeakMarshaller)
    {
        _dobj = dobj;
        _svc = svc;
    }

    public function get dobj () :DObject
    {
        return _dobj;
    }

    public function startRouting () :void
    {
        _dobj.addListener(this);
    }

    public function stopRouting () :void
    {
        _dobj.removeListener(this);
    }

    public function get speakMarshaller () :SpeakMarshaller
    {
        return _svc;
    }

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
            _chatDir.receiveSpeak(Speak(value));

        } else {
            log.warning("Got unhandled message type", "eventName", event.getName(), "event", event);
            return;
        }
    }

    protected var _dobj :DObject;
    protected var _svc :SpeakMarshaller;

    protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);

    private static const log :Log = Log.getLog(DObjectSpeakRouter);
}
}
