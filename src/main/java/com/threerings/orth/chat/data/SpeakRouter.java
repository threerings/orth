//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.presents.dobj.DObject;

/**
 * Indicates a Streamable should implement this interface in Actionscript. See the actionscript
 * interface for its functionality.
 */
public interface SpeakRouter
{
    DObject getSpeakObject ();
}
