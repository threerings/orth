//
// $Id$
package com.threerings.orth.world.client {

import com.threerings.orth.world.data.OrthPlace;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

/**
 * An ActionScript version of the Java WorldService interface.
 */
public interface WorldService extends InvocationService
{
    // from Java interface WorldService
    function moveTo (arg1 :OrthPlace, arg2 :WorldService_WorldMoveListener) :void;
}
}
