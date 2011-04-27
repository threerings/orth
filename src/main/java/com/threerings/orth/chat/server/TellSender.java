//
// $Id$

package com.threerings.orth.chat.server;

import com.threerings.orth.chat.client.TellDecoder;
import com.threerings.orth.chat.client.TellReceiver;
import com.threerings.orth.chat.data.Tell;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationSender;

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
