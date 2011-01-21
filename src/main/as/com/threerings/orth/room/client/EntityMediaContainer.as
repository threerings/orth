//
// $Id: MsoyMediaContainer.as 19763 2010-12-08 03:07:58Z zell $

package com.threerings.orth.room.client {

import flash.display.LoaderInfo;

import flash.events.Event;
import flash.events.IEventDispatcher;

import mx.core.Application;
import mx.core.FlexGlobals;
import mx.core.ISWFBridgeProvider;

import mx.events.SWFBridgeEvent;

import mx.managers.IMarshalSystemManager;

import com.threerings.util.Capabilities;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.ui.MediaDescContainer;

public class EntityMediaContainer extends MediaDescContainer
    implements ISWFBridgeProvider
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

    // from ISWFBridgeProvider
    public function get swfBridge () :IEventDispatcher
    {
        return _bridge;
    }

    // from ISWFBridgeProvider
    public function get childAllowsParent () :Boolean
    {
        return true;
    }

    // from ISWFBridgeProvider
    public function get parentAllowsChild () :Boolean
    {
        return false;
    }

    override protected function addListeners (info :LoaderInfo) :void
    {
        super.addListeners(info);

        if (Capabilities.isFlash10() && "uncaughtErrorEvents" in Object(info.loader)) {
            Object(info.loader).uncaughtErrorEvents.addEventListener(
                "uncaughtError", handleUncaughtErrors);
        }
        info.sharedEvents.addEventListener(SWFBridgeEvent.BRIDGE_NEW_APPLICATION, bridgeApp);
    }

    override protected function removeListeners (info :LoaderInfo) :void
    {
        super.removeListeners(info);

        if (Capabilities.isFlash10() && "uncaughtErrorEvents" in Object(info.loader)) {
            Object(info.loader).uncaughtErrorEvents.removeEventListener(
                "uncaughtError", handleUncaughtErrors);
        }
        info.sharedEvents.removeEventListener(SWFBridgeEvent.BRIDGE_NEW_APPLICATION, bridgeApp);
    }

    protected function handleUncaughtErrors (event :*) :void
    {
        log.info("Uncaught Error", "media", _desc, event);
    }

    protected function bridgeApp (event :Event) :void
    {
        _bridge = IEventDispatcher(event.currentTarget);
        var app :Application = Application(FlexGlobals.topLevelApplication);
        var msm :IMarshalSystemManager = IMarshalSystemManager(
            app.systemManager.getImplementation("mx.managers::IMarshalSystemManager"));
        msm.addChildBridge(_bridge, this);
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
