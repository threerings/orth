//
// $Id$
package com.threerings.orth.world.data {

import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.world.client.WorldService_PlaceResolutionListener;

/**
 * Marshalls instances of the WorldService_PlaceResolutionMarshaller interface.
 */
public class WorldMarshaller_PlaceResolutionMarshaller
    extends InvocationMarshaller_ListenerMarshaller
{
    /** The method id used to dispatch <code>placeLocated</code> responses. */
    public static const PLACE_LOCATED :int = 1;

    /** The method id used to dispatch <code>resolutionFailed</code> responses. */
    public static const RESOLUTION_FAILED :int = 2;

    // from InvocationMarshaller_ListenerMarshaller
    override public function dispatchResponse (methodId :int, args :Array) :void
    {
        switch (methodId) {
        case PLACE_LOCATED:
            (listener as WorldService_PlaceResolutionListener).placeLocated(
                (args[0] as OrthPlace));
            return;

        case RESOLUTION_FAILED:
            (listener as WorldService_PlaceResolutionListener).resolutionFailed(
                (args[0] as PlaceKey), (args[1] as String));
            return;

        default:
            super.dispatchResponse(methodId, args);
            return;
        }
    }
}
}
