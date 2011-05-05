//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client.editor {

import flash.display.BitmapData;
import flash.geom.Matrix;

import com.threerings.orth.entity.client.FurniSprite;
import com.threerings.orth.room.data.OrthLocation;

public class EntranceSprite extends FurniSprite
{
    public function initEntranceSprite (location :OrthLocation) :void
    {
        // fake furni data for the fake sprite
        var furniData :EntranceFurniData = new EntranceFurniData();
        furniData.media = null;
        furniData.loc = location;
        super.initFurniSprite(furniData);

        _sprite.setMediaClass(_rsrc.edEntrance);
        setLocation(location);
    }

    // from DataPackMediaContainer
    override public function snapshot (
        bitmapData :BitmapData, matrix :Matrix, childPredicate :Function = null) :Boolean
    {
        return true; // do nothing, don't raise a stink
    }

    // from FurniSprite
    override public function isRemovable () :Boolean
    {
        return false;
    }

    // from FurniSprite
    override public function isActionModifiable () :Boolean
    {
        return false;
    }
}
}
