//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.chat.data;

import javax.annotation.Generated;

import com.threerings.orth.chat.client.TellService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;

/**
 * Provides the implementation of the {@link TellService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from TellService.java.")
public class TellMarshaller extends InvocationMarshaller
    implements TellService
{
    /** The method id used to dispatch {@link #sendTell} requests. */
    public static final int SEND_TELL = 1;

    // from interface TellService
    public void sendTell (int arg1, String arg2, InvocationService.ConfirmListener arg3)
    {
        InvocationMarshaller.ConfirmMarshaller listener3 = new InvocationMarshaller.ConfirmMarshaller();
        listener3.listener = arg3;
        sendRequest(SEND_TELL, new Object[] {
            Integer.valueOf(arg1), arg2, listener3
        });
    }
}
