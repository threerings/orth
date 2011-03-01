//
// $Id: MsoyMediaContainer.as 19763 2010-12-08 03:07:58Z zell $

package com.threerings.orth.room.client {
import flash.display.LoaderInfo;
import flash.events.IEventDispatcher;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.ui.MediaDescContainer;

public class EntityMediaContainer extends MediaDescContainer
{
    public function EntityMediaContainer (
        desc :MediaDesc = null, suppressHitTestPoint :Boolean = false)
    {
        super(desc);
        _suppressHitTestPoint = suppressHitTestPoint;
    }

    public function setSuppressHitTestPoint (suppress :Boolean) :void
    {
        _suppressHitTestPoint = suppress;
    }

    public function setMaxContentDimensions (width :int, height :int) :void
    {
        _maxWidth = width;
        _maxHeight = height;
    }

    // documentation inherited
    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        if (_suppressHitTestPoint) {
            return false;
        }
        return super.hitTestPoint(x, y, shapeFlag);
    }

    /** @inheritDoc */
    // from MediaContainer
    override public function getMediaScaleX () :Number
    {
        return _spriteMediaScaleX;
    }

    /** @inheritDoc */
    // from MediaContainer
    override public function getMediaScaleY () :Number
    {
        return _spriteMediaScaleY;
    }

    /**
     * Set the media scale to use when we are not displaying a blocked state.
     */
    public function setSpriteMediaScale (scaleX :Number, scaleY :Number) :void
    {
        _spriteMediaScaleX = scaleX;
        _spriteMediaScaleY = scaleY;
    }

    override public function getMaxContentWidth () :int
    {
        return _maxWidth;
    }

    override public function getMaxContentHeight () :int
    {
        return _maxHeight;
    }

    public function getUnscaledWidth () :Number
    {
        return _w;
    }

    public function getUnscaledHeight () :Number
    {
        return _h;
    }

    protected function handleUncaughtErrors (event :*) :void
    {
        log.info("Uncaught Error", "media", _desc, event);
    }

    protected var _suppressHitTestPoint :Boolean;

    protected var _maxWidth :int = int.MAX_VALUE;
    protected var _maxHeight :int = int.MAX_VALUE;

    /** The media scale to use when we are not blocked. */
    protected var _spriteMediaScaleX :Number = 1.0;

    /** The media scale to use when we are not blocked. */
    protected var _spriteMediaScaleY :Number = 1.0;

    protected var _bridge :IEventDispatcher;
}
}
