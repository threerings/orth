//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data {

import com.threerings.util.Name;

/**
 * Implemented by PlaceObjects that take over the PlaceView completely. (ie, not AVRGs)
 */
public interface PrimaryPlace
{
    /**
     * Get the name of this place.
     */
    function getName () :Name;
}
}
