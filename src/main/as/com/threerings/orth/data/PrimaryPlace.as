//
// $Id: PrimaryPlace.as 17833 2009-08-14 23:34:17Z ray $

package com.threerings.orth.data {

import com.threerings.util.Name;

/**
 * Implemented by PlaceObjects that take over the PlaceView completely. (ie, not AVRGs)
 */
public interface PrimaryPlace
{
    /**
     * Get the name of this place.
     */
    function getName () :Name;
}
}
