//
// $Id: $

package com.threerings.orth.entity.data;

/**
 * Client-side information about the kind of entity that can be the backdrop canvas for a room.
 */
public interface Decor
    extends Entity
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
