//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.client {

import com.threerings.presents.client.InvocationDecoder;

import com.threerings.orth.chat.data.Tell;

/**
 * Dispatches calls to a {@link TellReceiver} instance.
 */
public class TellDecoder extends InvocationDecoder
{
    /** The generated hash code used to identify this receiver class. */
    public static const RECEIVER_CODE :String = "a4088b52895d5283a0004cef213f02f9";

    /** The method id used to dispatch {@link TellReceiver#receiveTell}
     * notifications. */
    public static const RECEIVE_TELL :int = 1;

    /**
     * Creates a decoder that may be registered to dispatch invocation
     * service notifications to the specified receiver.
     */
    public function TellDecoder (receiver :TellReceiver)
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
        case RECEIVE_TELL:
            TellReceiver(receiver).receiveTell(
                (args[0] as Tell)
            );
            return;

        default:
            super.dispatchNotification(methodId, args);
        }
    }
}
}
