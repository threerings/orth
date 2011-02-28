//
// $Id: EntranceSprite.as 19528 2010-11-09 18:00:15Z zell $

package com.threerings.orth.room.client.editor {

import flash.display.BitmapData;

import flash.geom.Matrix;

import com.threerings.orth.room.client.FurniSprite;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.data.MediaDescImpl;

public class EntranceSprite extends FurniSprite
{
    public function initEntranceSprite (location :OrthLocation) :void
    {
        // fake furni data for the fake sprite
        var furniData :EntranceFurniData = new EntranceFurniData();
        furniData.media = null;
        furniData.loc = location;
        super.initFurniSprite(furniData);

        _sprite.setMediaClass(inject(OrthResourceFactory).getEntrance());
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
