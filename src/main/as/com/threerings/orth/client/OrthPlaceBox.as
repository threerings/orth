//
// $Id: PlaceBox.as 18849 2009-12-14 20:14:44Z ray $

package com.threerings.orth.client {

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.geom.Point;

import mx.core.UIComponent;

/**
 * A component that holds our main view and sets up a mask to ensure that it doesn't render
 * outside the box's bounds.
 */
public class OrthPlaceBox extends LayeredContainer
{
    public function OrthPlaceBox (ctx :OrthContext)
    {
        _octx = ctx;
        rawChildren.addChild(_mask = new Shape());
    }

    public function getMainView () :DisplayObject
    {
        return _mainView;
    }

    public function setMainView (view :DisplayObject) :void
    {
        // throw an exception now if it's not a display object
        setBaseLayer(view);
        _mainView = view;

        layoutMainView();
    }

    override public function addOverlay (overlay :DisplayObject, layer :int) :void
    {
        super.addOverlay(overlay, layer);

        // inform the new child of the place size if it implement the layer interface
        if (overlay is PlaceLayer) {
            PlaceLayer(overlay).setPlaceSize(width, height);
        }
    }

    public function clearMainView (view :DisplayObject) :Boolean
    {
        if ((_mainView != null) && (view == null || view == _mainView)) {
            clearBaseLayer();
            _mainView = null;
            return true;
        }
        return false;
    }

    /**
     * @return true if there are glyphs under the specified point.  If the glyph extends
     * InteractiveObject and the glyph sprite has mouseEnabled == false, it is not checked.
     */
    public function overlaysMousePoint (stageX :Number, stageY :Number) :Boolean
    {
        var stagePoint :Point = new Point(stageX, stageY);
        for (var ii :int = 0; ii < numChildren; ii ++) {
            var child :DisplayObject = unwrap(getChildAt(ii));
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
     * This must be called on when our size is changed to allow us update our MainView mask and
     * resize the MainView itself.
     */
    override public function setActualSize (width :Number, height :Number) :void
    {
        super.setActualSize(width, height);

        setMasked(this, 0, 0, this.width, this.height);

        // any PlaceLayer layers get informed of the size change
        for (var ii :int = 0; ii < numChildren; ii ++) {
            var child :DisplayObject = unwrap(getChildAt(ii));
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
        var w :Number = this.width;
        var h :Number = this.height;

        var fullSize :Point = _lastFullSize;
        if (fullSize == null) {
            fullSize = new Point(w + 700, h);
        }

        _base.x = 0;
        _base.y = 0;

        if (_mainView is UIComponent) {
            UIComponent(_mainView).setActualSize(w, h);
        } else if (_mainView is PlaceLayer) {
            PlaceLayer(_mainView).setPlaceSize(w, h);
        } else if (_mainView != null) {
            log.warning("MainView is not a PlaceLayer or an UIComponent.");
        }
    }

    protected function setMasked (
        disp :DisplayObject, x :Number, y : Number, w :Number, h :Number) :void
    {
        if (_masked != disp) {
            if (_masked != null) {
                _masked.mask = null;
            }
            _masked = disp;
            if (_masked != null) {
                _masked.mask = _mask;
            }
        }
        _mask.graphics.clear();
        _mask.graphics.beginFill(0xFFFFFF);
        _mask.graphics.drawRect(x, y, w, h);
        _mask.graphics.endFill();
    }

    /** The river of life. */
    protected var _octx :OrthContext;

    /** The mask configured on the box or view so that it doesn't overlap outside components. */
    protected var _mask :Shape = new Shape();

    /** The object currently being masked, either this or _placeView. */
    protected var _masked :DisplayObject;

    /** The current place view. */
    protected var _mainView :DisplayObject;

    /** The size of the area the last time he had an unminimized layout. */
    protected var _lastFullSize :Point;
}
}
