//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.client {
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Matrix;

import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthRoomCodes;

/**
 * A Sprite that implements RoomElement. For subclassing or using to draw effects or
 * editing artifacts in the room.
 */
public class RoomElementSprite extends Sprite
    implements RoomElement
{
    // from RoomElement
    public function getVisualization () :DisplayObject
    {
        return this;
    }

    // from RoomElement
    public function setLocation (newLoc :Object) :void
    {
        _loc.set(newLoc);
    }

    // from RoomElement
    public function getLocation () :OrthLocation
    {
        return _loc;
    }

    // from RoomElement
    public function isImportant () :Boolean
    {
        return false;
    }

    // from RoomElement
    public function snapshot (
        bitmapData :BitmapData, matrix :Matrix, childPredicate :Function = null) :Boolean
    {
        return true; // we do nothing, innocuously
    }

    // from RoomElement
    public function getLayoutType () :int
    {
        return OrthRoomCodes.LAYOUT_NORMAL;
    }

    // from RoomElement
    public function getRoomLayer () :int
    {
        return OrthRoomCodes.FOREGROUND_LAYER;
    }

    // from RoomElement
    public function setScreenLocation (x :Number, y :Number, scale :Number) :void
    {
        this.x = x
        this.y = y
        this.scaleX = scale;
        this.scaleY = scale;
    }

    /** Our logical location. */
    protected const _loc :OrthLocation = new OrthLocation();
}
}
