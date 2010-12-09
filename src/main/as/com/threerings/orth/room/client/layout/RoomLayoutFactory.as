//
// $Id: RoomLayoutFactory.as 14311 2009-01-09 19:46:49Z ray $

package com.threerings.orth.room.client.layout {
import com.threerings.orth.room.data.DecorCodes;
import com.threerings.orth.room.data.DecorGeometry;

import com.threerings.orth.room.client.RoomView;

/**
 * Collection of static classes for testing and creating layout instances.
 */
public class RoomLayoutFactory {

    /**
     * Returns true if the specified layout supports the specified decor type.
     * Single layout can support multiple decor types.
     */
    public static function isDecorSupported (layout :RoomLayout, decor :DecorGeometry) :Boolean
    {
        var layoutClass :Class = layoutClassForDecor(decor);
        return Object(layout).constructor === layoutClass;
    }

    /**
     * Creates a new, uninitialized room layout instance for the specified decor.
     */
    public static function createLayout (decor :DecorGeometry, view :RoomView) :RoomLayout
    {
        var layoutClass :Class = layoutClassForDecor(decor);
        return new layoutClass(view);
    }

    /**
     * Returns a layout class appropriate for the given decor type.
     */
    protected static function layoutClassForDecor (decor :DecorGeometry) :Class
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
