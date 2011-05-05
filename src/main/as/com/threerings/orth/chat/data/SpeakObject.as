//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.chat.data {

import com.threerings.presents.dobj.DObject;

import com.threerings.orth.chat.data.SpeakMarshaller;

/**
 * Implemented by any {@link DObject} that wishes to partake of the Orth chatting system's
 * "speak" ability, i.e. broadcast to all players currently subscribe to the given object.
 * This is how we distribute chats in rooms, games, parties, and so forth.
 */
public interface SpeakObject
{
    /** Simply returns the object in its {@link DObject} type. */
    function asDObject () :DObject;

    /** Returns the object's {@link SpeakMarshaller} member. */
    function getSpeakService () :SpeakMarshaller;
}
}
