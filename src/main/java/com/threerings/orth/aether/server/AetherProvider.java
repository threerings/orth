//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

import com.threerings.orth.aether.client.AetherService;
import com.threerings.orth.aether.data.AetherClientObject;

/**
 * Defines the server-side of the {@link AetherService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from AetherService.java.")
public interface AetherProvider extends InvocationProvider
{
    /**
     * Handles a {@link AetherService#acceptGuildInvite} request.
     */
    void acceptGuildInvite (AetherClientObject caller, int arg1, int arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;

    /**
     * Handles a {@link AetherService#createGuild} request.
     */
    void createGuild (AetherClientObject caller, String arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link AetherService#dispatchDeferredNotifications} request.
     */
    void dispatchDeferredNotifications (AetherClientObject caller);
}
