//
// $Id: DecorSprite.as 19413 2010-10-15 19:28:43Z zell $

package com.threerings.orth.entity.client {
import com.threerings.orth.scene.data.FurniData;
import com.threerings.orth.scene.data.OrthLocation;
import com.threerings.util.Log;

import flash.events.Event;

public class DecorSprite extends FurniSprite
{
    /**
     * Construct a new DecorSprite.
     */
    public function DecorSprite (ctx :WorldContext, decor :Decor)
    {
        var furniData :FurniData = makeFurniData(decor);
        super(ctx, furniData);
        setLocation(furniData.loc);

        _sprite.setSuppressHitTestPoint(true);
        _sprite.addEventListener(Event.COMPLETE, handleMediaComplete);
    }

    /**
     * Call the provided function when this particular sprite is done loading
     */
    public function setLoadedCallback (fn :Function) :void
    {
        _loadedCallback = fn;
    }

    override public function getRoomLayer () :int
    {
        return OrthSceneCodes.DECOR_LAYER;
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
            return "DecorSprite[type=" + _furni.itemType + ", id=" + _furni.itemId +
                ", loc=" + _furni.loc + ", media=" + _furni.media.getMediaPath() + "]";
        } else {
            return "DecorSprite[null]";
        }
    }

    /** Creates a transient furni data object, to feed to the superclass. */
    protected function makeFurniData (decor :Decor) :FurniData
    {
        var furniData :FurniData = new FurniData();
        furniData.itemType = Item.DECOR;
        furniData.itemId = decor.itemId;
        furniData.media = decor.getRawFurniMedia();

        // sprite location: center and up-front, but shifted by specified offset
        furniData.loc = new OrthLocation(0.5, 0, 0);

        return furniData;
    }

    protected function handleMediaComplete (event :Event) :void
    {
        if (_loadedCallback != null) {
            _loadedCallback();
        }
    }

    /** A function we call when we've finished loading. */
    protected var _loadedCallback :Function;
}
}
