//
// $Id$
package com.threerings.orth.world.client {

import com.threerings.presents.client.InvocationService_InvocationListener;

import com.threerings.orth.world.data.OrthPlace;
import com.threerings.orth.world.data.PlaceKey;

/**
 * An ActionScript version of the Java WorldService_PlaceResolutionListener interface.
 */
public interface WorldService_PlaceResolutionListener
    extends InvocationService_InvocationListener
{
    // from Java WorldService_PlaceResolutionListener
    function placeLocated (arg1 :OrthPlace) :void

    // from Java WorldService_PlaceResolutionListener
    function resolutionFailed (arg1 :PlaceKey, arg2 :String) :void
}
}
