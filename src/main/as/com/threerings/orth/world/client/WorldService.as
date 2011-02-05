//
// $Id$
package com.threerings.orth.world.client {

import com.threerings.presents.client.InvocationService;

import com.threerings.orth.world.data.PlaceKey;

/**
 * An ActionScript version of the Java WorldService interface.
 */
public interface WorldService extends InvocationService
{
    // from Java interface WorldService
    function locatePlace (arg1 :PlaceKey, arg2 :WorldService_PlaceResolutionListener) :void;
}
}
