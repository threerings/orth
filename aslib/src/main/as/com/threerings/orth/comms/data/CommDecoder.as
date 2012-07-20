//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.comms.data {

import com.threerings.presents.client.InvocationDecoder;

/**
 * Dispatches calls to a {@link CommReceiver} instance.
 */
public class CommDecoder extends InvocationDecoder
{
    /** The generated hash code used to identify this receiver class. */
    public static const RECEIVER_CODE :String = "4083f6b0ef0854b1c54c9fb77d43601f";

    /** The method id used to dispatch {@link CommReceiver#receiveComm}
     * notifications. */
    public static const RECEIVE_COMM :int = 1;

    /**
     * Creates a decoder that may be registered to dispatch invocation
     * service notifications to the specified receiver.
     */
    public function CommDecoder (receiver :CommReceiver)
    {
        this.receiver = receiver;
    }

    public override function getReceiverCode () :String
    {
        return RECEIVER_CODE;
    }

    public override function dispatchNotification (methodId :int, args :Array) :void
    {
        switch (methodId) {
        case RECEIVE_COMM:
            CommReceiver(receiver).receiveComm(
                (args[0] as Object)
            );
            return;

        default:
            super.dispatchNotification(methodId, args);
        }
    }
}
}
