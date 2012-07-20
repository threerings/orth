//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.orth.aether.client.IgnoreService;

/**
 * Provides the implementation of the {@link IgnoreService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from IgnoreService.java.")
public class IgnoreMarshaller extends InvocationMarshaller<AetherClientObject>
    implements IgnoreService
{
    /** The method id used to dispatch {@link #ignorePlayer} requests. */
    public static final int IGNORE_PLAYER = 1;

    // from interface IgnoreService
    public void ignorePlayer (int arg1, boolean arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(IGNORE_PLAYER, new Object[] {
            Integer.valueOf(arg1), Boolean.valueOf(arg2), listener3
        });
    }
}
