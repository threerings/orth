//
// $Id: MsoyPlaceView.as 19431 2010-10-22 22:08:36Z zell $

package com.threerings.orth.client {

import flash.geom.Point;

import com.threerings.crowd.client.PlaceView;

import com.threerings.orth.data.MediaDesc;

/**
 * An expanded PlaceView interface that can be used by views that wish to learn about their actual
 * pixel dimensions.
 */
public interface OrthPlaceView extends PlaceView, PlaceLayer
{
    /**
     * Inform the place view whether or not it's showing.
     */
    function setIsShowing (showing :Boolean) :void;

    /**
     * Indicates if we should use the chat overlay for this place.
     */
    function shouldUseChatOverlay () :Boolean;

    /**
     * Get the place name, or null if none.
     */
    function getPlaceName () :String;

    /**
     * Get the place logo, thumbnail media descriptor, or null if none.
     */
    function getPlaceLogo () :MediaDesc;

    /**
     * Returns true if this place view should be centered in the box.
     */
    function isCentered () :Boolean;

    /**
     * Gets the size of the content for this place view. A point is used as the return
     * value for convenience. x is width, y is height.
     */
    function getSize () :Point;

    /**
     * Gets the zoomable interface for this view, or null if not supported.
     */
    function asZoomable () :Zoomable;
}
}
