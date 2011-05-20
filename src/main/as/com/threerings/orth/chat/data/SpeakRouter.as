//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data {

import com.threerings.presents.dobj.DObject;

import com.threerings.orth.chat.data.SpeakMarshaller;

/**
 * Routes messages through the Orth chatting system's "speak" ability, i.e. broadcast to all
 * players currently subscribe to the given object. This is how we distribute chats in rooms,
 * games, parties, and so forth.
 */
public interface SpeakRouter
{
    /** Returns the {@link DObject} that receives SPEAK_MSG_TYPE for this location. */
    function get speakObject () :DObject;

    /** Returns the {@link SpeakMarshaller} to send messages for this location. */
    function get speakMarshaller () :SpeakMarshaller;
}
}
