//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.chat.client.TellService;
import com.threerings.orth.data.PlayerName;

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
    void sendTell (AetherClientObject caller, PlayerName arg1, String arg2, InvocationService.ConfirmListener arg3)
        throws InvocationException;
}
