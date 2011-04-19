//
// $Id: MsoyPlaceView.as 19431 2010-10-22 22:08:36Z zell $

package com.threerings.orth.client {

import flash.geom.Point;

import com.threerings.crowd.client.PlaceView;

/**
 * An expanded PlaceView interface that can be used by views that wish to learn about their actual
 * pixel dimensions.
 */
public interface OrthPlaceView extends PlaceView, PlaceLayer
{
    /**
     * Get the place name, or null if none.
     */
    function getPlaceName () :String;

    /**
     * Gets the size of the content for this place view. A point is used as the return
     * value for convenience. x is width, y is height.
     */
    function getSize () :Point;
}
}
