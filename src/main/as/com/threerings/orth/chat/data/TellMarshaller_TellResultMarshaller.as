//
// $Id$
package com.threerings.orth.chat.data {

import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.chat.client.TellService_TellResultListener;

/**
 * Marshalls instances of the TellService_TellResultMarshaller interface.
 */
public class TellMarshaller_TellResultMarshaller
    extends InvocationMarshaller_ListenerMarshaller
{
    /** The method id used to dispatch <code>tellSucceeded</code> responses. */
    public static const TELL_SUCCEEDED :int = 1;

    // from InvocationMarshaller_ListenerMarshaller
    override public function dispatchResponse (methodId :int, args :Array) :void
    {
        switch (methodId) {
        case TELL_SUCCEEDED:
            (listener as TellService_TellResultListener).tellSucceeded(
                );
            return;

        default:
            super.dispatchResponse(methodId, args);
            return;
        }
    }
}
}
