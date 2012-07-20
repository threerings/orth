//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.client;

import com.threerings.presents.client.InvocationDecoder;

import com.threerings.orth.chat.data.Tell;

/**
 * Dispatches calls to a {@link TellReceiver} instance.
 */
public class TellDecoder extends InvocationDecoder
{
    /** The generated hash code used to identify this receiver class. */
    public static final String RECEIVER_CODE = "a4088b52895d5283a0004cef213f02f9";

    /** The method id used to dispatch {@link TellReceiver#receiveTell}
     * notifications. */
    public static final int RECEIVE_TELL = 1;

    /**
     * Creates a decoder that may be registered to dispatch invocation
     * service notifications to the specified receiver.
     */
    public TellDecoder (TellReceiver receiver)
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
        case RECEIVE_TELL:
            ((TellReceiver)receiver).receiveTell(
                (Tell)args[0]
            );
            return;

        default:
            super.dispatchNotification(methodId, args);
            return;
        }
    }
}
