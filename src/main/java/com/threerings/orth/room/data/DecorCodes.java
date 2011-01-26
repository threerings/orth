//
// $Id: $


package com.threerings.orth.room.data;

/**
 *
 */
public class DecorCodes
{
    /** Type constant for a standard room. The room will use standard layout, and its background
     *  image will be drawn behind all furniture. */
    public static final byte IMAGE_OVERLAY = 1;
    /** Type constant for a room whose background is fixed to the viewport, instead of scene. */
    public static final byte FIXED_IMAGE = 2;
    /** Type constant for a room with non-standard, flat layout. */
    public static final byte FLAT_LAYOUT = 3;
    /** Type constant for a room with a bird's eye view layout. */
    public static final byte TOPDOWN_LAYOUT = 4;
    /** The number of type constants. */
    public static final int TYPE_COUNT = 5;
}
