//
// $Id$
package com.threerings.orth.room.client {

import flash.geom.Point;
import flash.geom.Rectangle;

import com.threerings.display.FrameSprite;
import com.threerings.util.MathUtil;
import com.threerings.util.Name;

import com.threerings.orth.chat.client.ChatInfoProvider;
import com.threerings.orth.chat.client.SpeakerObserver;
import com.threerings.orth.client.PlaceLayer;
import com.threerings.orth.entity.client.MemberSprite;


/**
 * This class functions as a scrolling viewport onto an actual {@link RoomView}.
 */
public class RoomWindow extends FrameSprite
    implements ChatInfoProvider, PlaceLayer
{
    public function RoomWindow (view :RoomView)
    {
        super(true);
        _view = view;

        this.addChild(view);
        view.x = SOME_BIG_NUMBER;
        view.y = SOME_BIG_NUMBER;
    }

    public function get roomView () :RoomView
    {
        return _view;
    }

    // from PlaceLayer
    public function setPlaceSize (unscaledWidth :Number, unscaledHeight :Number) :void
    {
        _view.setPlaceSize(unscaledWidth, unscaledHeight);
        _width = unscaledWidth;
        _height = unscaledHeight;
        setScrollOffset(new Point(0, -unscaledHeight));
        _jumpY = false;
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

    override protected function handleFrame (... ignored) :void
    {
        // for now, we just follow the current player; this is easily expanded/generalized
        var me :MemberSprite = _view.getMyAvatar();
        if (me == null) {
            return;
        }

        // fetch the basic geometry of our view
        var scrollBounds :Rectangle = _view.getScrollBounds();

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
            scrollTo.x = currentScroll.x + MathUtil.clamp(dX, -MAX_AUTO_SCROLL, MAX_AUTO_SCROLL);
            _jumpX ||= (Math.abs(dX) <= MAX_AUTO_SCROLL);
        }
        if (!_jumpY) {
            var dY :Number = newEdgeY - currentScroll.y;
            scrollTo.y = currentScroll.y + MathUtil.clamp(dY, -MAX_AUTO_SCROLL, MAX_AUTO_SCROLL);
            _jumpY ||= (Math.abs(dY) <= MAX_AUTO_SCROLL);
        }

        if (!scrollTo.equals(_lastOffset)) {
            // let the room know what we're about to do
            _view.notifyScroll(scrollTo);
            _lastOffset = scrollTo;
        }

        setScrollOffset(scrollTo);
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

    protected var _view :RoomView;
    protected var _width :int;
    protected var _height :int;

    protected var _jumpX :Boolean = true;
    protected var _jumpY :Boolean = true;

    protected var _lastOffset :Point = new Point(0, 0);

    /** The position within this window that we place our child, letting us scroll fully. */
    protected static const SOME_BIG_NUMBER :int = 10000;

    /** The maximum number of pixels to autoscroll per frame. */
    protected static const MAX_AUTO_SCROLL :int = 15;
}
}
