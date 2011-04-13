//
// $Id: LayeredContainer.as 15000 2009-02-24 00:24:42Z mdb $

package com.threerings.orth.client {

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.utils.Dictionary;

/**
 * Provide an organized way for callers to layer display objects onto one another at
 * different priority levels (which they will have to work out amongst themselves).
 *
 * This is by no means foolproof and calls can easily be made directly to the Sprite
 * we extend; it's still an improvement on separate pieces of our code base remotely
 * fiddling with rawChildren and competing for the top spot.
 */
public class SimpleLayeredContainer extends Sprite
    implements LayeredContainer
{
    public function asSprite () :Sprite
    {
        return this;
    }

    public function setBaseLayer (base:DisplayObject):void
    {
        clearBaseLayer();
        addChildAt(_base = base, 0);
    }

    public function clearBaseLayer ():void
    {
        if (_base != null) {
            removeChild(_base);
            _base = null;
        }
    }

    // from interface Snapshottable
    public function snapshot (
        bitmapData :BitmapData, matrix :Matrix, childPredicate :Function = null) :Boolean
    {
        return SnapshotUtil.snapshot(this, bitmapData, matrix,
            // enhance the predicate to avoid snapping the base
            function (disp :DisplayObject) :Boolean {
                return (disp != _base) && (childPredicate == null || childPredicate(disp));
            });
    }

    public function addOverlay (overlay:DisplayObject, layer:int):void
    {
        _layers[overlay] = layer;
        // step through the children until we find one whose layer is larger than ours
        for (var ii:int = 0; ii < numChildren; ii++) {
            if (getLayer(getChildAt(ii)) > layer) {
                addChildAt(overlay, ii);
                return;
            }
        }
        // if no such child found, just append
        addChild(overlay);
    }

    public function removeOverlay (overlay:DisplayObject):void
    {
        delete _layers[overlay];
        // remove this child from the display the hard way
        for (var ii:int = 0; ii < numChildren; ii++) {
            var child:DisplayObject = getChildAt(ii);
            if (child == overlay) {
                child = removeChildAt(ii);
                break;
            }
        }
    }

    public function containsOverlay (overlay:DisplayObject):Boolean
    {
        return (overlay in _layers);
    }

    public function getLayer (overlay:DisplayObject):int
    {
        return int(_layers[overlay]);
    }

    /** A mapping of overlays to the numerical layer priority at which they were added. */
    protected var _layers :Dictionary = new Dictionary(true);

    /** The base layer against which all other layers are relative. */
    protected var _base :DisplayObject;
}
}
