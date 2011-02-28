//
// $Id: EntranceSprite.as 19528 2010-11-09 18:00:15Z zell $

package com.threerings.orth.room.client.editor {

import flash.display.BitmapData;

import flash.geom.Matrix;


import com.threerings.orth.room.client.RoomContext;

import com.threerings.orth.room.client.FurniSprite;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.data.MediaDescImpl;

public class EntranceSprite extends FurniSprite
{
    /** The sprite image used for positioning the entrance location. */
    [Embed(source="../../../../../../../../rsrc/media/entrance.png")]
    public static const MEDIA_CLASS :Class;

    public function EntranceSprite (ctx :RoomContext, location :OrthLocation)
    {
        // fake furni data for the fake sprite
        var furniData :EntranceFurniData = new EntranceFurniData();
        furniData.media = null;
        furniData.loc = location;
        super(ctx, furniData);

        _sprite.setMediaClass(MEDIA_CLASS);
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
