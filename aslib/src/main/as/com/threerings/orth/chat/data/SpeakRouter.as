//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.data {

/**
 * Routes messages through the Orth chatting system's "speak" ability, i.e. broadcast to all
 * players currently subscribe to the given object. This is how we distribute chats in rooms,
 * games, parties, and so forth.
 */
public interface SpeakRouter
{
    function startRouting () :void;

    function stopRouting () :void;

    /** Returns the {@link SpeakMarshaller} to send messages for this location. */
    function get speakMarshaller () :SpeakMarshaller;
}
}
