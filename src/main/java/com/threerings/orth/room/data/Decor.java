//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.orth.ui.ObjectMediaDesc;

/**
 * Client-side information about the kind of entity that can be the backdrop canvas for a room.
 */
public interface Decor
{
    float getHorizon ();

    short getDepth ();

    short getWidth ();

    short getHeight ();

    float getActorScale ();

    float getFurniScale ();

    byte getDecorType ();

    ObjectMediaDesc getWalkability();
}
