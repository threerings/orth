//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.data
{
import com.threerings.presents.dobj.DObject;

/**
 * Any DObject-based place that can offer up a SpeakMarshaller.
 */
public interface SpeakPlace
{
    /** Returns the DObject that must underly this SpeakPlace. */
    function getDObject () :DObject;

    function getSpeakService () :SpeakMarshaller;
}
}
