//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.client {
import flashx.funk.ioc.inject;

import com.threerings.util.Log;
import com.threerings.util.MessageManager;

import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.chat.data.SpeakPlace;
import com.threerings.orth.data.OrthCodes;

/**
 * A fake chat director that just gives us something non-null to put in the
 * {@link RoomContext} and which also takes advantage of the somewhat ugly
 * but convenient fact that {@link PlaceManager} makes explicit calls into
 * this class whenever the player enters or leaves a location. We forward
 * these calls to our real, aether-level chat director.
 */
public class FakeChatDirector extends ChatDirector
{
    public function FakeChatDirector ()
    {
        super(inject(RoomContext), inject(MessageManager), OrthCodes.CHAT_MSGS);
    }

    override public function displayFeedback (bundle :String, message :String) :void
    {
        Log.getLog(this).info("displayFeedback", "bundle", bundle, "message", message);
    }

    override public function enteredLocation (place :PlaceObject) :void
    {
        if (place is SpeakPlace) {
            _chatDir.enteredLocation(SpeakPlace(place));
        }
    }

    override public function leftLocation (place :PlaceObject) :void
    {
        if (place is SpeakPlace) {
            _chatDir.leftLocation(SpeakPlace(place));
        }
    }

    protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);
}
}
