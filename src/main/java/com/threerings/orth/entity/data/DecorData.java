//
// $Id$

package com.threerings.orth.entity.data;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.data.EntityIdent;

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

    /** Deserializing constructor. */
    public DecorData ()
    {
    }

    /** Initializing constructor. */
    public DecorData (String name, MediaDesc media, EntityIdent ident, byte type, short width,
        short height, short depth, float horizon, float actorScale, float furniScale)
    {
        super(name, media, ident);

        this.type = type;
        this.width = width;
        this.height = height;
        this.depth = depth;
        this.horizon = horizon;
        this.actorScale = actorScale;
        this.furniScale = furniScale;
    }

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
