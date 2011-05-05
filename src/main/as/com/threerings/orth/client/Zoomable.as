//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.client {

/**
 * Optional mix-in for MsoyPlaceView implementations, exposed via MsoyPlaceView.asZoomable.
 */
public interface Zoomable
{
    /**
     * Gets the current zoom of the place.
     */
    function getZoom () :String;

    /**
     * Sets the current zoom of the place. Note that this need not adjust the layout since the
     * place container must by definition call update the place size after a zoom change.
     */
    function setZoom (zoom :String) :void;

    /**
     * Gets the array of possible zoom settings for the place.
     */
    function defineZooms () :Array /* of String */;

    /**
     * Gets the translated name of the current zoom level for display in the user interface.
     */
    function translateZoom () :String;
}
}
