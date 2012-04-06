//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

import com.threerings.orth.aether.client.IgnoreService;
import com.threerings.orth.aether.data.AetherClientObject;

/**
 * Defines the server-side of the {@link IgnoreService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from IgnoreService.java.")
public interface IgnoreProvider extends InvocationProvider
{
    /**
     * Handles a {@link IgnoreService#ignorePlayer} request.
     */
    void ignorePlayer (AetherClientObject caller, int arg1, boolean arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;
}
