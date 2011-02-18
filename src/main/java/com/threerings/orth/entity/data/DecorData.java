//
// $Id$

package com.threerings.orth.entity.data;

/**
 * A basic streamable implementation of {@link Decor}.
 */
public class DecorData extends EntityData
    implements Decor
{
    public byte type;
    public short width;
    public short height;
    public short depth;
    public float horizon;
    public float actorScale;
    public float furniScale;

    // from Decor
    public float getHorizon () {
        return horizon;
    }

    // from Decor
    public short getDepth () {
        return depth;
    }

    // from Decor
    public short getWidth () {
        return width;
    }

    // from Decor
    public short getHeight () {
        return height;
    }

    // from Decor
    public float getActorScale () {
        return actorScale;
    }

    // from Decor
    public float getFurniScale () {
        return furniScale;
    }

    // from Decor
    public byte getDecorType () {
        return type;
    }
}
