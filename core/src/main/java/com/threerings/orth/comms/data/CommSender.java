//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.comms.data;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationSender;

import com.threerings.orth.comms.data.CommDecoder;
import com.threerings.orth.comms.data.CommReceiver;

/**
 * Used to issue notifications to a {@link CommReceiver} instance on a
 * client.
 */
public class CommSender extends InvocationSender
{
    /**
     * Issues a notification that will result in a call to {@link
     * CommReceiver#receiveComm} on a client.
     */
    public static void receiveComm (
        ClientObject target, Object arg1)
    {
        sendNotification(
            target, CommDecoder.RECEIVER_CODE, CommDecoder.RECEIVE_COMM,
            new Object[] { arg1 });
    }

}
