//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.party.client.PartyRegistryService;
import com.threerings.orth.party.data.PartyConfig;

/**
 * Defines the server-side of the {@link PartyRegistryService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PartyRegistryService.java.")
public interface PartyRegistryProvider extends InvocationProvider
{
    /**
     * Handles a {@link PartyRegistryService#createParty} request.
     */
    void createParty (AetherClientObject caller, PartyConfig arg1, InvocationService.ResultListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyRegistryService#joinParty} request.
     */
    void joinParty (AetherClientObject caller, int arg1, InvocationService.ResultListener arg2)
        throws InvocationException;
}
