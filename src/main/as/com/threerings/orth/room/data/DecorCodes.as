package com.threerings.orth.scene.data
{
public class DecorCodes
{
    /** Type constant for a room with no background, just bare walls. This constant is deprecated,
     *  please do not use. Legacy decor of this type will be drawn using default type. */
    const DRAWN_ROOM_DEPRECATED :int = 0;

    /** Type constant for a standard room. The room will use standard layout, and its background
     *  image will be drawn behind all furniture. */
    public static const IMAGE_OVERLAY :int = 1;

    /** Type constant for a room whose background is fixed to the viewport, instead of scene. */
    public static const FIXED_IMAGE :int = 2;

    /** Type constant for a room with non-standard, flat layout. */
    public static const FLAT_LAYOUT :int = 3;

    /** Type constant for a room with a bird's eye view layout. */
    public static const TOPDOWN_LAYOUT :int = 4;

    /** The number of type constants. */
    public static const TYPE_COUNT :int = 5;
}
}
