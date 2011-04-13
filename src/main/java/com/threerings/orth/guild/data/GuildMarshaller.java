//
// $Id$

package com.threerings.orth.guild.data;

import javax.annotation.Generated;

import com.threerings.orth.guild.client.GuildService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;

/**
 * Provides the implementation of the {@link GuildService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from GuildService.java.")
public class GuildMarshaller extends InvocationMarshaller
    implements GuildService
{
    /** The method id used to dispatch {@link #sendInvite} requests. */
    public static final int SEND_INVITE = 1;

    // from interface GuildService
    public void sendInvite (int arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(SEND_INVITE, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }
}
