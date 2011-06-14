//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import javax.annotation.Generated;

import com.threerings.orth.party.client.PartyRegistryService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

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
    void createParty (ClientObject caller, String arg1, boolean arg2, PartyRegistryService.JoinListener arg3)
        throws InvocationException;

    /**
     * Handles a {@link PartyRegistryService#locateParty} request.
     */
    void locateParty (ClientObject caller, int arg1, PartyRegistryService.JoinListener arg2)
        throws InvocationException;
}
