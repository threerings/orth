//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.client;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.presents.client.InvocationDecoder;

/**
 * Dispatches calls to a {@link FriendReceiver} instance.
 */
public class FriendDecoder extends InvocationDecoder
{
    /** The generated hash code used to identify this receiver class. */
    public static final String RECEIVER_CODE = "bd7ab9871632a7a369ba754e139f8908";

    /** The method id used to dispatch {@link FriendReceiver#friendshipRequested}
     * notifications. */
    public static final int FRIENDSHIP_REQUESTED = 1;

    /**
     * Creates a decoder that may be registered to dispatch invocation
     * service notifications to the specified receiver.
     */
    public FriendDecoder (FriendReceiver receiver)
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
        case FRIENDSHIP_REQUESTED:
            ((FriendReceiver)receiver).friendshipRequested(
                (PlayerName)args[0]
            );
            return;

        default:
            super.dispatchNotification(methodId, args);
            return;
        }
    }
}
