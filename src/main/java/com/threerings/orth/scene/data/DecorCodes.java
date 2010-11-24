//
// $Id: $


package com.threerings.orth.scene.data;

/**
 *
 */
public class DecorCodes
{
    /** Type constant for a room with no background, just bare walls. This constant is deprecated,
     *  please do not use. Legacy decor of this type will be drawn using default type. */
    public static final byte DRAWN_ROOM_DEPRECATED = 0;
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
