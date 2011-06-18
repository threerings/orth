//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client;

import com.threerings.presents.client.InvocationService;

/**
 * Provides party services accessed via a world session.
 */
public interface PartyRegistryService extends InvocationService
{
    /**
     * Creates a new party with the requester as its leader. Sends a PartyObjectAddress back.
     */
    void createParty (ResultListener rl);
}
