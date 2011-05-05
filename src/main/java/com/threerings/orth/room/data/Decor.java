//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.data;

import com.threerings.orth.entity.data.Walkability;

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

    Walkability getWalkability ();
}
