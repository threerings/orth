//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import javax.annotation.Generated;

import com.threerings.orth.chat.client.TellService;
import com.threerings.orth.data.OrthName;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link TellService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from TellService.java.")
public interface TellProvider extends InvocationProvider
{
    /**
     * Handles a {@link TellService#sendTell} request.
     */
    void sendTell (ClientObject caller, OrthName arg1, String arg2, InvocationService.ConfirmListener arg3)
        throws InvocationException;
}
