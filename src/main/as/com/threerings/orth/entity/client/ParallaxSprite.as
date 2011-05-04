//
// $Id$

package com.threerings.orth.entity.client {

import flash.geom.Point;

import com.threerings.orth.room.data.OrthRoomCodes;

/**
 * A simple subclass that modifies the layout behaviour of a Furni as follows:
 *  - the media is anchored in the lower left, i.e. (0, 0)
 *  - the sprite is lain out in the PARALLAX style, which is very similar to DECOR
 */
public class ParallaxSprite extends FurniSprite
{
    // from RoomElement
    override public function getRoomLayer () :int
    {
        return _furni.loc.z >= 1.0 ? OrthRoomCodes.DECOR_LAYER : OrthRoomCodes.FURNITURE_LAYER;
    }

    // from RoomElement
    override public function getLayoutType () :int
    {
        return OrthRoomCodes.LAYOUT_PARALLAX;
    }

    override protected function calculateHotspot (
        contentWidth :Number, contentHeight :Number) :Point
    {
        // we anchor in the lower left, not the lower middle
        return new Point(0, 0);
    }

    override public function capturesMouse () :Boolean
    {
        return false;
    }

    override public function toString () :String
    {
        return "ParallaxSprite[" + _furni.item + "]";
    }
}
}
