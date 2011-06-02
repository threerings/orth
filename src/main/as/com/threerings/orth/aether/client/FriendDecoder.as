//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.client {

import com.threerings.presents.client.InvocationDecoder;

import com.threerings.orth.aether.data.PlayerName;

/**
 * Dispatches calls to a {@link FriendReceiver} instance.
 */
public class FriendDecoder extends InvocationDecoder
{
    /** The generated hash code used to identify this receiver class. */
    public static const RECEIVER_CODE :String = "bd7ab9871632a7a369ba754e139f8908";

    /** The method id used to dispatch {@link FriendReceiver#friendshipAccepted}
     * notifications. */
    public static const FRIENDSHIP_ACCEPTED :int = 1;

    /** The method id used to dispatch {@link FriendReceiver#friendshipRequested}
     * notifications. */
    public static const FRIENDSHIP_REQUESTED :int = 2;

    /**
     * Creates a decoder that may be registered to dispatch invocation
     * service notifications to the specified receiver.
     */
    public function FriendDecoder (receiver :FriendReceiver)
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
        case FRIENDSHIP_ACCEPTED:
            FriendReceiver(receiver).friendshipAccepted(
                (args[0] as PlayerName)
            );
            return;

        case FRIENDSHIP_REQUESTED:
            FriendReceiver(receiver).friendshipRequested(
                (args[0] as PlayerName)
            );
            return;

        default:
            super.dispatchNotification(methodId, args);
        }
    }
}
}
