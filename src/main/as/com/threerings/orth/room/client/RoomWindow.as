//
// $Id$
package com.threerings.orth.room.client {

import flash.geom.Point;
import flash.geom.Rectangle;

import com.threerings.display.FrameSprite;
import com.threerings.util.MathUtil;
import com.threerings.util.Name;

import com.threerings.crowd.data.PlaceObject;

import com.threerings.orth.chat.client.ChatInfoProvider;
import com.threerings.orth.chat.client.SpeakerObserver;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.PlaceLayer;
import com.threerings.orth.client.OrthPlaceView;
import com.threerings.orth.client.Zoomable;
import com.threerings.orth.entity.client.MemberSprite;

/**
 * This class functions as a scrolling viewport onto an actual {@link RoomView}.
 */
public class RoomWindow extends FrameSprite
    implements OrthPlaceView, ChatInfoProvider, PlaceLayer, Zoomable
{
    /** Fixed height of 500 (if available). */
    public static const LETTERBOX :String = "letter_box";

    /** Scale up or down to consume all height available. */
    public static const FULL_HEIGHT :String = "full_height";

    /** Fit the width of the room in the width of the view. */
    public static const FIT_WIDTH :String = "fit_width";

    public function RoomWindow (view :RoomView)
    {
        super(true);
        _view = view;

        this.addChild(view);
        view.x = SOME_BIG_NUMBER;
        view.y = SOME_BIG_NUMBER;

        setZoom(FULL_HEIGHT);
    }

    public function get roomView () :RoomView
    {
        return _view;
    }

    // from Zoomable
    public function defineZooms () :Array /* of String */
    {
        return [ LETTERBOX, FULL_HEIGHT, FIT_WIDTH ];
    }

    // from Zoomable
    public function getZoom () :String
    {
        if (_zoom == null) {
            _zoom = defineZooms()[0];
        }
        return _zoom;
    }

    // from Zoomable
    public function setZoom (zoom :String) :void
    {
        _zoom = zoom;
    }

    // from Zoomable
    public function translateZoom () :String
    {
        switch (getZoom()) {
        case LETTERBOX: return Msgs.WORLD.get("l.zoom_letterbox");
        case FULL_HEIGHT: return Msgs.WORLD.get("l.full_height");
        case FIT_WIDTH: return Msgs.WORLD.get("l.fit_width");
        }
        return _zoom;
    }

    // from PlaceView
    public function willEnterPlace (plobj : PlaceObject) : void
    {
        _view.willEnterPlace(plobj);
    }

    // from PlaceView
    public function didLeavePlace (plobj : PlaceObject) : void
    {
        _view.didLeavePlace(plobj);
    }

    // from PlaceLayer
    public function setPlaceSize (unscaledWidth :Number, unscaledHeight :Number) :void
    {
        _width = unscaledWidth;
        _height = unscaledHeight;

        // TODO: do this bit conditionally
        setScrollOffset(new Point(0, -200));
        _jumpY = false;

        relayout();
    }

    // from ChatInfoProvider
    public function getBubblePosition (speaker :Name) :Point
    {
        return _view.getBubblePosition(speaker);
    }

    // from ChatInfoProvider
    public function addBubbleObserver (observer :SpeakerObserver) :void
    {
        _view.addBubbleObserver(observer);
    }

    // from ChatInfoProvider
    public function removeBubbleObserver (observer :SpeakerObserver) :void
    {
        _view.removeBubbleObserver(observer);
    }

    /**
     * Get the full boundaries of our scrolling area in scaled (decor pixel) dimensions.
     * The Rectangle returned may be destructively modified.
     */
    public function getScrollBounds () :Rectangle
    {
        var r :Rectangle = new Rectangle(0, 0, _width / scaleX, _height / scaleY);
        if (_view.getScene() != null) {
            r.width = Math.min(_view.metrics.sceneWidth, r.width);
            r.height = Math.min(_view.metrics.sceneHeight, r.height);
        }
        return r;
    }

    override protected function handleFrame (... ignored) :void
    {
        // for now, we just follow the current player; this is easily expanded/generalized
        var me :MemberSprite = _view.getMyAvatar();
        if (me == null) {
            return;
        }

        // fetch the basic geometry of our view
        var scrollBounds :Rectangle = getScrollBounds();

        // where do we ideally want the center of the viewport to be?
        var targetCenterX :int = me.viz.x + me.getLayoutHotSpot().x;

        // to accomplish that, what scroll offset would be required?
        var newEdgeX :Number = targetCenterX - scrollBounds.width/2;

        // finally clamp that urge to realistic values
        newEdgeX = MathUtil.clamp(newEdgeX, 0, _view.getScene().getWidth() - scrollBounds.width);

        // for now, our only Y urge is to not have any offset at all
        var newEdgeY :Number = 0;

        var currentScroll :Point = getScrollRectangle().topLeft;
        var scrollTo :Point = new Point(newEdgeX, newEdgeY);
        if (!_jumpX) {
            var dX :Number = newEdgeX - currentScroll.x;
            scrollTo.x = currentScroll.x + easeIn(dX, 1.0);
        }
        if (!_jumpY) {
            var dY :Number = newEdgeY - currentScroll.y;
            scrollTo.y = currentScroll.y + easeIn(dY, 0.3);
        }

        if (!scrollTo.equals(_lastOffset)) {
            // let the room know what we're about to do
            _view.notifyScroll(scrollTo);
            _lastOffset = scrollTo;
        }

        setScrollOffset(scrollTo);
    }

    // let the step adjustment by clamped by the square root of the step distance
    protected function easeIn (d :Number, pace :Number) :Number
    {
        var m :Number = Math.pow(Math.abs(d * pace), 0.25);
        return MathUtil.clamp(d, -m, m);
    }

    protected function getScrollRectangle () :Rectangle
    {
        var rect :Rectangle = this.scrollRect;
        return new Rectangle(rect.x - SOME_BIG_NUMBER, rect.y - SOME_BIG_NUMBER, _width, _height);
    }

    protected function setScrollOffset (offset :Point) :void
    {
        scrollRect = new Rectangle(
            offset.x + SOME_BIG_NUMBER, offset.y + SOME_BIG_NUMBER, _width, _height);
    }

    protected function relayout () :void
    {
        const letterboxHeight :int = 500;
        var scale :Number;
        switch (getZoom()) {
        case LETTERBOX:
            scale = Math.min(letterboxHeight, _height) / _view.metrics.sceneHeight;
            break;
        case FULL_HEIGHT:
            scale = _height / _view.metrics.sceneHeight;
            break;
        case FIT_WIDTH:
            scale = Math.min(_height / _view.metrics.sceneHeight,
                             _width / _view.metrics.sceneWidth,
                             letterboxHeight / _view.metrics.sceneHeight);
            break;
        }

        scaleY = scale;
        scaleX = scale;

        _view.relayout();
    }

    protected var _view :RoomView;

    protected var _width :int;
    protected var _height :int;

    protected var _jumpX :Boolean = true;
    protected var _jumpY :Boolean = true;

    protected var _zoom :String;

    protected var _lastOffset :Point = new Point(0, 0);

    /** The position within this window that we place our child, letting us scroll fully. */
    protected static const SOME_BIG_NUMBER :int = 10000;
}
}
