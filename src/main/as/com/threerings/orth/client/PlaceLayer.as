//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.client {

/**
 * An interface implemented by components that wish to reside inside a PlaceView panel
 * and thus respond to changes in that panel's dimensions.
 */
public interface PlaceLayer
{
    /**
     * Informs the place view of its pixel dimensions.
     */
    function setPlaceSize (unscaledWidth :Number, unscaledHeight :Number) :void;
}
}
