//
// $Id$
package com.threerings.orth.world.data {

import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.orth.world.client.WorldService;
import com.threerings.orth.world.client.WorldService_WorldMoveListener;

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
    /** The method id used to dispatch <code>moveTo</code> requests. */
    public static const MOVE_TO :int = 1;

    // from interface WorldService
    public function moveTo (arg1 :OrthPlace, arg2 :WorldService_WorldMoveListener) :void
    {
        var listener2 :WorldMarshaller_WorldMoveMarshaller = new WorldMarshaller_WorldMoveMarshaller();
        listener2.listener = arg2;
        sendRequest(MOVE_TO, [
            arg1, listener2
        ]);
    }
}
}
