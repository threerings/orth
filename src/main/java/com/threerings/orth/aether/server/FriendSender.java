//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import com.threerings.orth.aether.client.FriendDecoder;
import com.threerings.orth.aether.client.FriendReceiver;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationSender;

/**
 * Used to issue notifications to a {@link FriendReceiver} instance on a
 * client.
 */
public class FriendSender extends InvocationSender
{
    /**
     * Issues a notification that will result in a call to {@link
     * FriendReceiver#friendshipAccepted} on a client.
     */
    public static void friendshipAccepted (
        ClientObject target, PlayerName arg1)
    {
        sendNotification(
            target, FriendDecoder.RECEIVER_CODE, FriendDecoder.FRIENDSHIP_ACCEPTED,
            new Object[] { arg1 });
    }

    /**
     * Issues a notification that will result in a call to {@link
     * FriendReceiver#friendshipRequested} on a client.
     */
    public static void friendshipRequested (
        ClientObject target, PlayerName arg1)
    {
        sendNotification(
            target, FriendDecoder.RECEIVER_CODE, FriendDecoder.FRIENDSHIP_REQUESTED,
            new Object[] { arg1 });
    }

}
