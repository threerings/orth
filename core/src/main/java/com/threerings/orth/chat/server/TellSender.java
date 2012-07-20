//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationSender;

import com.threerings.orth.chat.client.TellDecoder;
import com.threerings.orth.chat.client.TellReceiver;
import com.threerings.orth.chat.data.Tell;

/**
 * Used to issue notifications to a {@link TellReceiver} instance on a
 * client.
 */
public class TellSender extends InvocationSender
{
    /**
     * Issues a notification that will result in a call to {@link
     * TellReceiver#receiveTell} on a client.
     */
    public static void receiveTell (
        ClientObject target, Tell arg1)
    {
        sendNotification(
            target, TellDecoder.RECEIVER_CODE, TellDecoder.RECEIVE_TELL,
            new Object[] { arg1 });
    }

}
