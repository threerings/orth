//
// $Id: DecorSprite.as 19413 2010-10-15 19:28:43Z zell $

package com.threerings.orth.entity.client {
import com.threerings.orth.entity.data.Decor;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthRoomCodes;
import com.threerings.util.Log;

import flash.events.Event;

public class DecorSprite extends FurniSprite
{
    /**
     * Initializes a new DecorSprite.
     */
    public function initDecorSprite (decor:Decor):void
    {
        var furniData :FurniData = makeFurniData(decor);
        super.initFurniSprite(furniData);

        setLocation(furniData.loc);

        _sprite.setSuppressHitTestPoint(true);
        _sprite.addEventListener(Event.COMPLETE, handleMediaComplete);
    }

    override public function getRoomLayer () :int
    {
        return OrthRoomCodes.DECOR_LAYER;
    }

    public function updateFromDecor (decor :Decor) :void
    {
        super.update(makeFurniData(decor));
    }

    override public function update (furni :FurniData) :void
    {
        Log.getLog(this).warning("Cannot update a decor sprite from furni data!");
    }

    override public function getDesc () :String
    {
        return "m.decor";
    }

    override public function getToolTipText () :String
    {
        // no tooltip
        return null;
    }

    // documentation inherited
    override public function hasAction () :Boolean
    {
        return false; // decor has no action
    }

    // documentation inherited
    override public function capturesMouse () :Boolean
    {
        return false; // decor does not capture mouse actions
    }

    override public function toString () :String
    {
        if (_furni != null) {
            return "DecorSprite[item=" + _furni.item + ", loc=" + _furni.loc + ", media=" +
                _furni.media + "]";
        } else {
            return "DecorSprite[null]";
        }
    }

    /** Creates a transient furni data object, to feed to the superclass. */
    protected function makeFurniData (decor :Decor) :FurniData
    {
        var furniData :FurniData = new FurniData();
        furniData.item = decor.getIdent();
        furniData.media = decor.getFurniMedia();
        furniData.scaleX = furniData.scaleY = 1;
        furniData.rotation = 0;

        // sprite location: center and up-front, but shifted by specified offset
        furniData.loc = new OrthLocation(0.5, 0, 0);

        return furniData;
    }

}
}
