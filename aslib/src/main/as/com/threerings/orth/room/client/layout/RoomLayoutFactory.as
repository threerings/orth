//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.client.layout {
import com.threerings.orth.room.client.RoomView;
import com.threerings.orth.room.data.Decor;
import com.threerings.orth.room.data.DecorCodes;

/**
 * Collection of static classes for testing and creating layout instances.
 */
public class RoomLayoutFactory {

    /**
     * Returns true if the specified layout supports the specified decor type.
     * Single layout can support multiple decor types.
     */
    public static function isDecorSupported (layout :RoomLayout, decor :Decor) :Boolean
    {
        var layoutClass :Class = layoutClassForDecor(decor);
        return Object(layout).constructor === layoutClass;
    }

    /**
     * Creates a new, uninitialized room layout instance for the specified decor.
     */
    public static function createLayout (decor :Decor, view :RoomView) :RoomLayout
    {
        var layoutClass :Class = layoutClassForDecor(decor);
        return new layoutClass(view);
    }

    /**
     * Returns a layout class appropriate for the given decor type.
     */
    protected static function layoutClassForDecor (decor :Decor) :Class
    {
        if (decor == null) {
            // this should only happen during room initialization
            return RoomLayoutStandard;
        }

        if (decor.getDecorType() == DecorCodes.FLAT_LAYOUT) {
            return RoomLayoutFlatworld;

        } else if (decor.getDecorType() == DecorCodes.TOPDOWN_LAYOUT) {
            return RoomLayoutTopdown;

        } else {
            return RoomLayoutStandard;
        }
    }
}
}
