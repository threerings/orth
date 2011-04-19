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
        _view = view;

        this.addChild(view);
    }

    public function get roomView () :RoomView
    {
        return _view;
    }

    // from PlaceLayer
    public function setPlaceSize (unscaledWidth :Number, unscaledHeight :Number) :void
    {
        _view.setPlaceSize(unscaledWidth, unscaledHeight);
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
        var newEdgeX :Number = targetCenterX - scrollBounds.width/2;
        newEdgeX = MathUtil.clamp(newEdgeX, 0, _view.getScene().getWidth() - scrollBounds.width);

        var newY :Number = 0;


        if (_jumpScroll) {
            scrollBounds.x = newEdgeX;
            scrollBounds.y = newY;

        } else {
            var dX :Number = newEdgeX - scrollBounds.x;
            var dY :Number = newY - scrollBounds.y;

            if (Math.max(Math.abs(dX), Math.abs(dY)) <= MAX_AUTO_SCROLL) {
                _jumpScroll = true;
            }

            scrollBounds.x += MathUtil.clamp(dX, -MAX_AUTO_SCROLL, MAX_AUTO_SCROLL);
            scrollBounds.y += MathUtil.clamp(dY, -MAX_AUTO_SCROLL, MAX_AUTO_SCROLL);
        }

        if (!scrollBounds.topLeft.equals(_lastOffset)) {
            // let the room know what we're about to do
            _view.notifyScroll(scrollBounds.topLeft);
            _lastOffset = scrollBounds.topLeft;
        }

        // assign the new scrolling rectangle
        scrollRect = scrollBounds;
    }

    protected var _view :RoomView;

    protected var _jumpScroll :Boolean = true; // start off rapid-centering

    protected var _lastOffset :Point = new Point(0, 0);

    /** The maximum number of pixels to autoscroll per frame. */
    protected static const MAX_AUTO_SCROLL :int = 15;
}
}
