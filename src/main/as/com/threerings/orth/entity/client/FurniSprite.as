//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.entity.client {
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.SecurityErrorEvent;
import flash.geom.Point;

import com.threerings.media.MediaContainer;

import com.threerings.util.CommandEvent;
import com.threerings.util.ValueEvent;

import com.threerings.orth.client.LoadingWatcher;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.room.client.RoomController;
import com.threerings.orth.room.data.FurniData;

public class FurniSprite extends EntitySprite
{
    /**
     * Set the LoadingWatcher that will be used to track whether any
     * FurniSprites are currently loading.
     */
    public static function setLoadingWatcher (watcher :LoadingWatcher) :void
    {
        _loadingWatcher = watcher;
    }

    /**
     * Initializes a new FurniSprite.
     */
    public function initFurniSprite (furni :FurniData):void
    {
        _furni = furni;

        _sprite.addEventListener(MouseEvent.ROLL_OVER, handleMouseHover);
        _sprite.addEventListener(MouseEvent.ROLL_OUT, handleMouseHover);
        _sprite.addEventListener(MediaContainer.LOADER_READY, handleLoaderReady);
        _sprite.addEventListener(Event.COMPLETE, loadingStopped);
        _sprite.removeEventListener(IOErrorEvent.IO_ERROR, loadingStopped);
        _sprite.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadingStopped);

        // configure our media and item
        setEntityIdent(furni.item);
        _sprite.setSpriteMediaScale(furni.scaleX, furni.scaleY);
        _sprite.setMediaDesc(furni.media);

        // set up our hotspot if one is configured in the furni data record
        if (_furni.hotSpotX !=0 || _furni.hotSpotY != 0) {
            _hotSpot = new Point(_furni.hotSpotX, _furni.hotSpotY);
        }
    }

    override public function getDesc () :String
    {
        return _furni.actionType.isPortal() ? "m.portal" : "m.furni";
    }

    public function getFurniData () :FurniData
    {
        return _furni;
    }

    /**
     * Call the provided function when this particular sprite is done loading
     */
    public function setLoadedCallback (fn :Function):void
    {
        _loadedCallback = fn;
        if (_complete) {
            _loadedCallback(this);
        }
    }

    /** Can this sprite be removed from the room? */
    public function isRemovable () :Boolean
    {
        return true;
    }

    /** Can this sprite's action be modified? */
    public function isActionModifiable () :Boolean
    {
        return true;
    }

    public function update (furni :FurniData) :void
    {
        _furni = furni;
        setEntityIdent(furni.item);
        _sprite.setMediaDesc(furni.media);
        scaleUpdated();
        rotationUpdated();
        setLocation(furni.loc);
    }

    override public function getToolTipText () :String
    {
        // clear out any residuals from the last action
        var actionData :Array = _furni.splitActionData();

        if (_furni.actionType.isNone()) {
            return null;
        }
        if (_furni.actionType.isPortal()) {
            return Msgs.GENERAL.get("i.trav_portal", String(actionData[actionData.length-1]));
        }
        if (_furni.actionType.isURL()) {
            // if there's no description, use the URL
            return String(actionData[actionData.length - 1]);
        }
        if (_furni.actionType.isHelpPage()) {
            return Msgs.GENERAL.get("i.help_page", String(actionData[0]));
        }
        log.warning("Tooltip: unknown furni action type", "actionType", _furni.actionType,
            "actionData", _furni.actionData);
        return null;
    }

    /**
     * If we're a portal furniture, called to animate a player entering
     * or leaving.
     */
    public function wasTraversed (entering :Boolean) :void
    {
        // TODO: pass body as arg? Pass dimensions of body as arg?
        // TODO: receive a path or some other descriptor of an animation
        //       for the body???

        // Note: these constants are defined in FurniControl, but there's  no way to reference
        // that without that class being compiled in, and constants are not inlined.
        // So- we've made the decision to a) Duplicate and b) Don't fuck up step a.
        messageReceived(entering ? "bodyEntered" : "bodyLeft", null, true);
    }

    override protected function scaleUpdated () :void
    {
        // update our visualization with the furni's current scale
        _sprite.setSpriteMediaScale(_furni.scaleX, _furni.scaleY);

        super.scaleUpdated();
    }

    override protected function createBackend () :EntityBackend
    {
        return _module.getInstance(FurniBackend);
    }

    override protected function useLocationScale () :Boolean
    {
        return !_furni.isNoScale();
    }

    override public function getMediaRotation () :Number
    {
        return _furni.rotation;
    }

    override public function setMediaRotation (rotation :Number) :void
    {
        _furni.rotation = rotation;
        rotationUpdated();
    }

    override public function setMediaScaleX (scaleX :Number) :void
    {
        _furni.scaleX = scaleX;
        scaleUpdated();
    }

    override public function setMediaScaleY (scaleY :Number) :void
    {
        _furni.scaleY = scaleY;
        scaleUpdated();
    }

    // documentation inherited
    override public function hasAction () :Boolean
    {
        return !_furni.actionType.isNone();
    }

    override public function capturesMouse () :Boolean
    {
        if (_furni.actionType.isNone()) {
            return (_furni.actionData == null);
        }
        return super.capturesMouse();
    }

    override public function toString () :String
    {
        return "FurniSprite[" + _furni.item + "]";
    }

    // documentation inherited
    override public function getHoverColor () :uint
    {
        return _furni.actionType.isPortal() ? PORTAL_HOVER : OTHER_HOVER;
    }

    override protected function postClickAction () :void
    {
        if (hasAction()) {
            CommandEvent.dispatch(_sprite, RoomController.FURNI_CLICKED, _furni);
        }
    }

    protected function loadingStopped (event :Event):void
    {
        _complete = true;
        if (_loadedCallback != null) {
            _loadedCallback(this);
            _loadedCallback = null;
        }
    }

    /**
     * Listens for ROLL_OVER and ROLL_OUT, which we only receive if the sprite
     * has action.
     */
    protected function handleMouseHover (event :MouseEvent) :void
    {
        callUserCode("mouseHover_v1", (event.type == MouseEvent.ROLL_OVER));
    }

    protected function handleLoaderReady (event :ValueEvent) :void
    {
        var info :LoaderInfo = (event.value as LoaderInfo);

        if (_loadingWatcher != null) {
            _loadingWatcher.watchLoader(info, _sprite);
        }
    }

    /** The furniture data for this piece of furni. */
    protected var _furni :FurniData;

    /** A function we call when we've finished loading. */
    protected var _loadedCallback:Function;

    /** Remember if loading completed (or failed). */
    protected var _complete :Boolean;

    /** The watcher for loading progress. */
    protected static var _loadingWatcher :LoadingWatcher;
}
}
