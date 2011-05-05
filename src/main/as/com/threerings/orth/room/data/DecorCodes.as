//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.data
{
public class DecorCodes
{
    /** Type constant for a standard room. The room will use standard layout, and its background
     *  image will be drawn behind all furniture. */
    public static const IMAGE_OVERLAY :int = 1;

    /** Type constant for a room with non-standard, flat layout. */
    public static const FLAT_LAYOUT :int = 3;

    /** Type constant for a room with a bird's eye view layout. */
    public static const TOPDOWN_LAYOUT :int = 4;

    /** The number of type constants. */
    public static const TYPE_COUNT :int = 5;
}
}
