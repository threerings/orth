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
    /** The method id used to dispatch {@link #disband} requests. */
    public static final int DISBAND = 1;

    // from interface GuildService
    public void disband (InvocationService.InvocationListener arg1)
    {
        ListenerMarshaller listener1 = new ListenerMarshaller();
        listener1.listener = arg1;
        sendRequest(DISBAND, new Object[] {
            listener1
        });
    }

    /** The method id used to dispatch {@link #leave} requests. */
    public static final int LEAVE = 2;

    // from interface GuildService
    public void leave (InvocationService.InvocationListener arg1)
    {
        ListenerMarshaller listener1 = new ListenerMarshaller();
        listener1.listener = arg1;
        sendRequest(LEAVE, new Object[] {
            listener1
        });
    }

    /** The method id used to dispatch {@link #remove} requests. */
    public static final int REMOVE = 3;

    // from interface GuildService
    public void remove (int arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(REMOVE, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #sendInvite} requests. */
    public static final int SEND_INVITE = 4;

    // from interface GuildService
    public void sendInvite (int arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(SEND_INVITE, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #updateRank} requests. */
    public static final int UPDATE_RANK = 5;

    // from interface GuildService
    public void updateRank (int arg1, GuildRank arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(UPDATE_RANK, new Object[] {
            Integer.valueOf(arg1), arg2, listener3
        });
    }
}
