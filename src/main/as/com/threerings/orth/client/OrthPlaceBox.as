//
// $Id: PlaceBox.as 18849 2009-12-14 20:14:44Z ray $

package com.threerings.orth.client {
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * A component that holds our main view and sets up a mask to ensure that it doesn't render
 * outside the box's bounds.
 */
public class OrthPlaceBox extends Sprite
    implements Snapshottable
{
    public function OrthPlaceBox ()
    {
        addChild(_layers);

        _layers.x = INNER_OFFSET.x;
        _layers.y = INNER_OFFSET.y;
    }


    public function setMainView (view :DisplayObject) :void
    {
        // throw an exception now if it's not a display object
        _layers.setBaseLayer(view);
        _mainView = view;

        layoutMainView();
    }

    public function getMainView () :DisplayObject
    {
        return _mainView;
    }

    public function clearMainView (view :DisplayObject) :Boolean
    {
        if ((_mainView != null) && (view == null || view == _mainView)) {
            _layers.clearBaseLayer();
            _mainView = null;
            return true;
        }
        return false;
    }

    // from LayeredContainer
    public function addPlaceOverlay (overlay :DisplayObject, layer :int) :void
    {
        _layers.addOverlay(overlay, layer);

        // inform the new child of the place size if it implement the layer interface
        if (overlay is PlaceLayer) {
            PlaceLayer(overlay).setPlaceSize(_layers.width, _layers.height);
        }
    }

    // from Snapshottable
    public function snapshot (bitmapData :BitmapData, matrix :Matrix,
        childPredicate :Function = null) :Boolean
    {
        return _layers.snapshot(bitmapData, matrix, childPredicate);
    }

    /**
     * @return true if there are glyphs under the specified point.  If the glyph extends
     * InteractiveObject and the glyph sprite has mouseEnabled == false, it is not checked.
     */
    public function overlaysMousePoint (stageX :Number, stageY :Number) :Boolean
    {
//        var stagePoint :Point = _layers.globalToLocal(new Point(stageX, stageY));
        for (var ii :int = 0; ii < _layers.numChildren; ii ++) {
            var child :DisplayObject = _layers.getChildAt(ii);
            if (child == _mainView) {
                continue;
            }
            // note that we want hitTestPoint() to be able to modify the value of the
            // child's mouseEnabled property, so do not reorder the following statements
            // in a fit of over-optimization
            if (!child.hitTestPoint(stageX, stageY, true)) {
                continue;
            }
            if (!(child is InteractiveObject) || (child as InteractiveObject).mouseEnabled) {
                return true;
            }
        }
        return false;
    }

    /**
     * This must be called on when our size is changed to allow us to resize the MainView itself.
     */
    public function setActualSize (width :Number, height :Number) :void
    {
        _width = width;
        _height = height;

        // any PlaceLayer layers get informed of the size change
        for (var ii :int = 0; ii < _layers.numChildren; ii ++) {
            var child :DisplayObject = _layers.getChildAt(ii);
            if (child == _mainView) {
                continue; // we'll handle this later
            } else if (child is PlaceLayer) {
                PlaceLayer(child).setPlaceSize(width, height);
            }
        }

        layoutMainView();
    }

    protected function layoutMainView () :void
    {
        if (_mainView is PlaceLayer) {
            PlaceLayer(_mainView).setPlaceSize(_width, _height);
        }

        updateScrollRect();
    }


    protected function updateScrollRect () :void
    {
        var rect :Rectangle = new Rectangle();
        rect.topLeft = INNER_OFFSET;
        rect.width = _width + INNER_OFFSET.x;
        rect.height = height + INNER_OFFSET.y;
        this.scrollRect = rect;
    }

    /** The configured width of the placebox. */
    protected var _width :Number;

    /** The configured height of the placebox. */
    protected var _height :Number;

    protected var _layers :SimpleLayeredContainer = new SimpleLayeredContainer();

    /** The current place view. */
    protected var _mainView :DisplayObject;

    protected static const INNER_OFFSET :Point = new Point(10000, 10000);
}
}
