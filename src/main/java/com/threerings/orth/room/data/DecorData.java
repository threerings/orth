//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.entity.data.Walkability;

/**
 */
public class DecorData extends SimpleStreamableObject
    implements Decor
{
    public byte type;
    public short width;
    public short height;
    public short depth;
    public float horizon;
    public float actorScale;
    public float furniScale;
    public boolean hideWalls;
    public Walkability walkability;

    /** Deserializing constructor. */
    public DecorData ()
    {
    }

    /** Initializing constructor. */
    public DecorData ( byte type, short width, short height, short depth, float horizon,
        float actorScale, float furniScale, Walkability walkability)
    {
        this.type = type;
        this.width = width;
        this.height = height;
        this.depth = depth;
        this.horizon = horizon;
        this.actorScale = actorScale;
        this.furniScale = furniScale;
        this.walkability = walkability;
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

    // from Decor
    public Walkability getWalkability () {
        return walkability;
    }
}
