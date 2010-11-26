//
// $Id: OrthMediaContainer.as 19252 2010-06-25 19:31:09Z zell $

package com.threerings.orth.ui {
import flash.display.Loader;
import flash.display.LoaderInfo;

import flash.events.Event;

import com.threerings.util.Capabilities;
import com.threerings.util.Util;

import com.threerings.media.MediaContainer;

import com.threerings.orth.data.MediaDesc;

public class OrthMediaContainer extends MediaContainer
{
    public function OrthMediaContainer (desc :MediaDesc = null)
    {
        super(null);
        if (desc != null) {
            setMediaDesc(desc);
        }
    }

    /**
     * ATTENTION: don't use this method in msoy unless you know what you're doing.
     * MediaDescs should almost always be used in msoy instead of urls.
     */
    override public function setMedia (url :String) :void
    {
        // this method exists purely for the change in documentation.
        super.setMedia(url);
    }

    /**
     * Set a new MediaDescriptor.
     */
    public function setMediaDesc (desc :MediaDesc) :void
    {
        if (Util.equals(desc, _desc)) {
            return;
        }

        _desc = desc;
        super.setMedia((desc == null) ? null : desc.getMediaPath());
    }

    /**
     * Retrieve the MediaDescriptor we're configured with, or null if we're not fully configured
     * yet, or media was configured through setMedia().
     */
    public function getMediaDesc () :MediaDesc
    {
        return _desc;
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

    /**
     * Set the media scale to use.
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

    override protected function addListeners (info :LoaderInfo) :void
    {
        super.addListeners(info);

        if (Capabilities.isFlash10() && "uncaughtErrorEvents" in Object(info.loader)) {
            Object(info.loader).uncaughtErrorEvents.addEventListener(
                "uncaughtError", handleUncaughtErrors);
        }
    }

    override protected function removeListeners (info :LoaderInfo) :void
    {
        super.removeListeners(info);

        if (Capabilities.isFlash10() && "uncaughtErrorEvents" in Object(info.loader)) {
            Object(info.loader).uncaughtErrorEvents.removeEventListener(
                "uncaughtError", handleUncaughtErrors);
        }
    }

    protected function handleUncaughtErrors (event :*) :void
    {
        // this is overridden in EntitySprite
        log.info("Uncaught Error", "media", _desc, event);
    }

    protected var _suppressHitTestPoint :Boolean;

    protected var _maxWidth :int = int.MAX_VALUE;
    protected var _maxHeight :int = int.MAX_VALUE;

    /** The media scale to use. */
    protected var _spriteMediaScaleX :Number = 1.0;

    /** The media scale to use. */
    protected var _spriteMediaScaleY :Number = 1.0;

    /** Our Media descriptor. */
    protected var _desc :MediaDesc;
}
}
