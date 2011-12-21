//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import java.util.Set;

import com.threerings.presents.dobj.DObject;

/**
 * Indicates a Streamable should implement this interface in Actionscript. See the actionscript
 * interface for its functionality.
 */
public interface SpeakRouter
{
    /**
     * Return the {@link DObject} we should post {@link OrthChatCodes.SPEAK_MSG_TYPE} on.
     */
    DObject getSpeakObject ();

    /**
     * Return the numerical ids of all the players that would currently receive a dispatched speak.
     */
    Set<Integer> getSpeakReceipients ();
}
