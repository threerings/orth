//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.client {
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.geom.Matrix;

import com.threerings.util.ObserverList;

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
    }

    public function setMainView (view :DisplayObject) :void
    {
        // throw an exception now if it's not a display object
        _layers.setBaseLayer(view);
        _mainView = view;

        layoutMainView();

        _observers.apply(function (obs :PlaceBoxObserver) :void {
            obs.mainViewDidChange(view);
        });
    }

    public function getMainView () :DisplayObject
    {
        return _mainView;
    }

    public function clearMainView () :Boolean
    {
        var result :Boolean = false;
        if (_mainView != null) {
            _layers.clearBaseLayer();
            _mainView = null;
            result = true;
        }
        _observers.apply(function (obs :PlaceBoxObserver) :void {
            obs.mainViewDidChange(null);
        });
        return result;
    }

    public function addObserver (observer :PlaceBoxObserver) :void
    {
        _observers.add(observer);
    }

    public function removeObserver (observer :PlaceBoxObserver) :void
    {
        _observers.remove(observer);
    }

    // from LayeredContainer
    public function addPlaceOverlay (overlay :DisplayObject, layer :int) :void
    {
        _layers.addOverlay(overlay, layer);

        // inform the new child of the place size if it implement the layer interface
        if (overlay is PlaceLayer) {
            PlaceLayer(overlay).setPlaceSize(_width, _height);
        }
    }

    // from LayeredContainer
    public function removePlaceOverlay (overlay :DisplayObject) :void
    {
        _layers.removeOverlay(overlay);
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
                PlaceLayer(child).setPlaceSize(_width, _height);
            }
        }

        layoutMainView();
    }

    protected function layoutMainView () :void
    {
        if (_mainView is PlaceLayer) {
            PlaceLayer(_mainView).setPlaceSize(_width, _height);
        }
    }

    /** The configured width of the placebox. */
    protected var _width :Number;

    /** The configured height of the placebox. */
    protected var _height :Number;

    protected var _layers :SimpleLayeredContainer = new SimpleLayeredContainer();

    /** The current place view. */
    protected var _mainView :DisplayObject;

    protected var _observers :ObserverList = new ObserverList(ObserverList.SAFE_IN_ORDER_NOTIFY);
}
}
