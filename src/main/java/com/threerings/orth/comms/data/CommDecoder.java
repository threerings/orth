//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.comms.data;

import com.threerings.presents.client.InvocationDecoder;

/**
 * Dispatches calls to a {@link CommReceiver} instance.
 */
public class CommDecoder extends InvocationDecoder
{
    /** The generated hash code used to identify this receiver class. */
    public static final String RECEIVER_CODE = "4083f6b0ef0854b1c54c9fb77d43601f";

    /** The method id used to dispatch {@link CommReceiver#receiveComm}
     * notifications. */
    public static final int RECEIVE_COMM = 1;

    /**
     * Creates a decoder that may be registered to dispatch invocation
     * service notifications to the specified receiver.
     */
    public CommDecoder (CommReceiver receiver)
    {
        this.receiver = receiver;
    }

    @Override
    public String getReceiverCode ()
    {
        return RECEIVER_CODE;
    }

    @Override
    public void dispatchNotification (int methodId, Object[] args)
    {
        switch (methodId) {
        case RECEIVE_COMM:
            ((CommReceiver)receiver).receiveComm(
                args[0]
            );
            return;

        default:
            super.dispatchNotification(methodId, args);
            return;
        }
    }
}
