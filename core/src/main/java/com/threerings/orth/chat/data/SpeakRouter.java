//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import java.util.Set;

import com.samskivert.util.ResultListener;

/**
 * Indicates a Streamable should implement this interface in Actionscript. See the actionscript
 * interface for its functionality.
 */
public interface SpeakRouter
{
    /** Route the speak to the destination audience. */
    void sendSpeak (Speak speak, ResultListener<Set<Integer>> listener);
}
