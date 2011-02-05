//
// $Id$
package com.threerings.orth.world.data {

import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.orth.world.client.WorldService;
import com.threerings.orth.world.client.WorldService_PlaceResolutionListener;

/**
 * Provides the implementation of the <code>WorldService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class WorldMarshaller extends InvocationMarshaller
    implements WorldService
{
    /** The method id used to dispatch <code>locatePlace</code> requests. */
    public static const LOCATE_PLACE :int = 1;

    // from interface WorldService
    public function locatePlace (arg1 :PlaceKey, arg2 :WorldService_PlaceResolutionListener) :void
    {
        var listener2 :WorldMarshaller_PlaceResolutionMarshaller = new WorldMarshaller_PlaceResolutionMarshaller();
        listener2.listener = arg2;
        sendRequest(LOCATE_PLACE, [
            arg1, listener2
        ]);
    }
}
}
