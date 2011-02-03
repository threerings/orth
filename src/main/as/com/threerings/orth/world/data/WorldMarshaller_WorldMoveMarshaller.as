//
// $Id$
package com.threerings.orth.world.data {

import com.threerings.io.TypedArray;

import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.world.client.WorldService_WorldMoveListener;

/**
 * Marshalls instances of the WorldService_WorldMoveMarshaller interface.
 */
public class WorldMarshaller_WorldMoveMarshaller
    extends InvocationMarshaller_ListenerMarshaller
{
    /** The method id used to dispatch <code>moveRequiresServerSwitch</code> responses. */
    public static const MOVE_REQUIRES_SERVER_SWITCH :int = 1;

    /** The method id used to dispatch <code>moveSucceeded</code> responses. */
    public static const MOVE_SUCCEEDED :int = 2;

    // from InvocationMarshaller_ListenerMarshaller
    override public function dispatchResponse (methodId :int, args :Array) :void
    {
        switch (methodId) {
        case MOVE_REQUIRES_SERVER_SWITCH:
            (listener as WorldService_WorldMoveListener).moveRequiresServerSwitch(
                (args[0] as String), (args[1] as TypedArray /* of int */));
            return;

        case MOVE_SUCCEEDED:
            (listener as WorldService_WorldMoveListener).moveSucceeded(
                (args[0] as int));
            return;

        default:
            super.dispatchResponse(methodId, args);
            return;
        }
    }
}
}
