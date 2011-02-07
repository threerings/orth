//
// $Id$
package com.threerings.orth.world.client {
import com.threerings.io.TypedArray;

import com.threerings.presents.client.InvocationService_InvocationListener;

import com.threerings.orth.world.data.OrthPlace;

/**
 * An ActionScript version of the Java WorldService_PlaceResolutionListener interface.
 */
public interface WorldService_PlaceResolutionListener
    extends InvocationService_InvocationListener
{
    // from Java WorldService_PlaceResolutionListener
    function placeLocated (arg1 :String, arg2 :TypedArray /* of int */, arg3 :OrthPlace) :void
}
}
