//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.client {

import flash.display.DisplayObject;
import flash.display.Sprite;

public interface LayeredContainer extends Snapshottable
{
    function asSprite () :Sprite;
    
    function setBaseLayer (base :DisplayObject) :void;

    function clearBaseLayer () :void;

    /**
     * Adds a display object to overlay the main view as it changes. The lower the layer argument,
     * the lower the overdraw priority the layer has among other layers. The supplied DisplayObject
     * must have a name and it mustn't conflict with any other overlay name. Fortunately if you
     * don't name your display object it will be assigned a unique name.
     */
    function addOverlay (overlay :DisplayObject, layer :int) :void;

    /**
     * Removes a previously added overlay.
     */
    function removeOverlay (overlay :DisplayObject) :void;

    /**
     * Return the layer of the specified overlay, or 0 if it's not present.
     */
    function getLayer (overlay :DisplayObject) :int;
}
}
