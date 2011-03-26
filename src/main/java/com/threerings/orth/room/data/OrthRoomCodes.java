package com.threerings.orth.room.data;

import com.threerings.presents.data.InvocationCodes;

/**
 * Codes and constants relating to the Room services.
 */
public interface OrthRoomCodes extends InvocationCodes
{
    /** A message event type dispatched on the room object. */
    public static final String SPRITE_MESSAGE = "sprMsg";

    /** A message event type dispatched on the room object. */
    public static final String SPRITE_SIGNAL = "sprSig";

    /** A room layer that is in front of normal furniture and such. */
    public static final byte FOREGROUND_LAYER = 0;

    /** The normal room layer where most things are placed. */
    public static final byte FURNITURE_LAYER = 1;

    /** The backmost layer, should only be occupied by decor objects. */
    public static final byte DECOR_LAYER = 2;
}
