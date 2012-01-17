//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.orth.aether.client.AetherService;

/**
 * Provides the implementation of the {@link AetherService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from AetherService.java.")
public class AetherMarshaller extends InvocationMarshaller<AetherClientObject>
    implements AetherService
{
    /** The method id used to dispatch {@link #acceptGuildInvite} requests. */
    public static final int ACCEPT_GUILD_INVITE = 1;

    // from interface AetherService
    public void acceptGuildInvite (int arg1, int arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(ACCEPT_GUILD_INVITE, new Object[] {
            Integer.valueOf(arg1), Integer.valueOf(arg2), listener3
        });
    }

    /** The method id used to dispatch {@link #createGuild} requests. */
    public static final int CREATE_GUILD = 2;

    // from interface AetherService
    public void createGuild (String arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(CREATE_GUILD, new Object[] {
            arg1, listener2
        });
    }
}
