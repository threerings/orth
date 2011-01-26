//
// $Id: PlaceBox.as 18849 2009-12-14 20:14:44Z ray $

package com.threerings.orth.client {

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.events.Event;
import flash.filters.GlowFilter;

import flash.geom.Point;
import flash.geom.Rectangle;

import mx.controls.Label;
import mx.core.UIComponent;

import caurina.transitions.Tweener;

import com.threerings.flex.CommandButton;
import com.threerings.flex.FlexUtil;

import com.threerings.util.ArrayUtil;
import com.threerings.util.NamedValueEvent;
import com.threerings.util.StringUtil;

import com.threerings.display.DisplayUtil;

import com.threerings.crowd.client.PlaceView;

/**
 * A component that holds our place views and sets up a mask to ensure that the place view does not
 * render outside the box's bounds.
 */
public class PlaceBox extends LayeredContainer
{
    /** The layer priority of help text bubbles. */
    public static const LAYER_HELP_BUBBLES :int = 5;

    /** The layer priority of the loading spinner. */
    public static const LAYER_ROOM_SPINNER :int = 10;

    /** The layer priority of the scrolling chat. */
    public static const LAYER_CHAT_SCROLL :int = 20;

    /** The layer priority of the occupant List. */
    public static const LAYER_CHAT_LIST :int = 25;

    /** The layer priority of non-moving chat messages. */
    public static const LAYER_CHAT_STATIC :int = 30;

    /** The layer priority of history chat messages. */
    public static const LAYER_CHAT_HISTORY :int = 35;

    /** The layer priority of place buttons. */
    public static const LAYER_PLACE_CONTROL :int = 45;

    /** The layer priority of the trophy award, avatar intro, and chat tip. */
    public static const LAYER_TRANSIENT :int = 50;

    public function PlaceBox (ctx :OrthContext)
    {
        _octx = ctx;
        rawChildren.addChild(_mask = new Shape());
    }

    public function getPlaceView () :PlaceView
    {
        return _placeView;
    }

    public function setPlaceView (view :PlaceView) :void
    {
        // throw an exception now if it's not a display object
        var disp :DisplayObject = DisplayObject(view);
        setBaseLayer(disp);
        _placeView = view;
        _orthPlaceView = view as OrthPlaceView;

        // TODO: why is this type-check here? surely when the place view changes it needs to be
        // laid out regardless of type
        if (_placeView is OrthPlaceView) {
            layoutPlaceView();
        }
    }

    override public function addOverlay (overlay :DisplayObject, layer :int) :void
    {
        super.addOverlay(overlay, layer);

        // inform the new child of the place size if it implement the layer interface
        if (overlay is PlaceLayer) {
            PlaceLayer(overlay).setPlaceSize(width, height);
        }
    }

    /**
     * Gets the background color of the current place or black if it is not an orth view.
     */
    public function getPlaceBackgroundColor () :uint
    {
        return 0x000000;
    }

    /**
     * Gets the background color of the frame, taking into account the user settings.
     */
    public function getFrameBackgroundColor () :uint
    {
        return 0xffffff;
    }

    /**
     * Updates the background color.
     */
    public function updateFrameBackgroundColor () :void
    {
        setStyle("backgroundColor", "#" + StringUtil.toHex(getFrameBackgroundColor(), 6));
    }

    public function clearPlaceView (view :PlaceView) :Boolean
    {
        if ((_placeView != null) && (view == null || view == _placeView)) {
            clearBaseLayer();
            _placeView = null;
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
            if (child == _placeView) {
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
     * This must be called on when our size is changed to allow us update our PlaceView mask and
     * resize the PlaceView itself.
     */
    override public function setActualSize (width :Number, height :Number) :void
    {
        super.setActualSize(width, height);

        if (_orthPlaceView == null) {
            setMasked(this, 0, 0, this.width, this.height);
        }

        // any PlaceLayer layers get informed of the size change
        for (var ii :int = 0; ii < numChildren; ii ++) {
            var child :DisplayObject = unwrap(getChildAt(ii));
            if (child == _placeView) {
                continue; // we'll handle this later
            } else if (child is PlaceLayer) {
                PlaceLayer(child).setPlaceSize(width, height);
            }
        }

        layoutPlaceView();
    }

    protected function layoutPlaceView () :void
    {
        var w :Number = this.width;
        var h :Number = this.height;

        var fullSize :Point = _lastFullSize;
        if (fullSize == null) {
            fullSize = new Point(w + 700, h);
        }

        _base.x = 0;
        _base.y = 0;

        // now inform the place view of its new size
        if (_orthPlaceView != null) {
            // center the view and add margins if view is centered
            var size :Point = null;
            var center :Boolean = _orthPlaceView.isCentered();
            if (center) {
                var wmargin :Number = 0;
                var hmargin :Number = 0;
                // set the margins somewhere between 0 and 20, making sure they don't cause
                // shrinking of an already small view
                // TODO: softwire 700x500
                wmargin = Math.max(0, Math.min(20, (fullSize.x - 700) / 2));
                hmargin = Math.max(0, Math.min(20, (fullSize.y - 500) / 2));
                _orthPlaceView.setPlaceSize(w - wmargin * 2, h - hmargin * 2);

                // NOTE: getSize must be called after setPlaceSize
                size = _orthPlaceView.getSize();
                if (size == null || isNaN(size.x) || isNaN(size.y)) {
                    center = false;
                }
            }

            var view :DisplayObject = _orthPlaceView as DisplayObject;
            if (center) {
                view.x = Math.max((w - size.x) / 2, wmargin);
                view.y = Math.max((h - size.y) / 2, hmargin);

                // TODO: the scrollRect in the room view takes care of cropping, we only require
                // masking if the view does *not* scroll - complicated!

                // mask it so that avatars and items don't bleed out of bounds
                size.x = Math.min(size.x, w - wmargin * 2);
                size.y = Math.min(size.y, h - hmargin * 2);
                setMasked(_base, view.x, view.y, size.x, size.y);
                bounds.left = view.x;
                bounds.top = view.y;
                bounds.size = size;

            } else {
                _orthPlaceView.setPlaceSize(w, h);
                setMasked(_base, 0, 0, w, h);
            }

        } else if (_placeView is UIComponent) {
            UIComponent(_placeView).setActualSize(w, h);
        } else if (_placeView is PlaceLayer) {
            PlaceLayer(_placeView).setPlaceSize(w, h);
        } else if (_placeView != null) {
            log.warning("PlaceView is not a PlaceLayer or an UIComponent.");
        }

        updateZoom(bounds);
        // TODO: bubble chat can currently overflow a restricted placeview size.
        // Fixing it was turning rabbit-holey, so I'm punting.
    }

    /**
     * Create and position the zoom button in the top right of the given bounds.
     */
    protected function updateZoom (bounds: Rectangle) :void
    {
        if (_zoomBtn != null) {
            removeOverlay(_zoomBtn);
            _zoomBtn = null;
        }

        if (_zoomLbl != null) {
            removeOverlay(_zoomLbl);
            Tweener.removeTweens(_zoomLbl);
            _zoomLbl = null;
        }

        var zoomable :Zoomable = _orthPlaceView != null ? _orthPlaceView.asZoomable() : null;
        if (zoomable == null) {
            return;
        }

        var zooms :Array = zoomable.defineZooms();
        var idx :int = ArrayUtil.indexOf(zooms, zoomable.getZoom());
        idx = (idx + 1) % zooms.length;

        const SIZE :int = 18;
        const PADDING :int = 1;
        _zoomBtn = new CommandButton();
        _zoomBtn.styleName = "placeZoomButton";
        _zoomBtn.toolTip = Msgs.GENERAL.get("l.change_zoom");
        _zoomBtn.x = Math.min(bounds.right + PADDING, width - SIZE - PADDING * 2);
        _zoomBtn.y = bounds.top + PADDING;
        addOverlay(_zoomBtn, LAYER_PLACE_CONTROL);

        _zoomBtn.setCallback(function () :void {
            zoomable.setZoom(zooms[idx]);
            _zoomChanged = true;
            layoutPlaceView();
        });

        const LBL_WIDTH :int = 150;
        const LBL_HEIGHT :int = 20;
        if (_zoomChanged) {
            _zoomChanged = false;
            _zoomLbl = FlexUtil.createLabel(zoomable.translateZoom(), "placeZoomLabel");
            _zoomLbl.filters = [new GlowFilter(0xffffff, 1, 8, 8, 4)];
            // TODO: WTF? why do I have to specify the width and height? Grrr
            _zoomLbl.width = LBL_WIDTH;
            _zoomLbl.height = LBL_HEIGHT;
            _zoomLbl.x = _zoomBtn.x - LBL_WIDTH;
            _zoomLbl.y = _zoomBtn.y;
            addOverlay(_zoomLbl, LAYER_PLACE_CONTROL);

            Tweener.addTween(_zoomLbl, {alpha: 0, time: _zoomLbl.getStyle("fade") as Number,
                delay: _zoomLbl.getStyle("delay") as Number, onComplete: function () :void {
                removeOverlay(_zoomLbl);
                _zoomLbl = null;
            }} );
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
    protected var _placeView :PlaceView;

    /** The current orth place view (may be null if not implemented). */
    protected var _orthPlaceView :OrthPlaceView;

    /** The size of the area the last time he had an unminimized layout. */
    protected var _lastFullSize :Point;

    /** The button for changing the zoom, if supported by the place. */
    protected var _zoomBtn :CommandButton;

    /** The label of the current zoom, shown when the zoom changes, then quickly faded. */
    protected var _zoomLbl :Label;

    /** Whether the zoom has changed (means we should flash the text. */
    protected var _zoomChanged :Boolean;
}
}
