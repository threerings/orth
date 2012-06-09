//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.client;

import com.threerings.presents.client.InvocationService;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.party.data.PartyConfig;

/**
 * Provides party services accessed via a world session.
 */
public interface PartyRegistryService extends InvocationService<AetherClientObject>
{
    /**
     * Creates a new party with the requester as its leader. Sends a HostedNodelet back.
     * 
     * Note that while the listener won't return until the party has been sucessfully created
     * and hosted on the server, the client still needs to connect and subscribe before any
     * operations will be successful.
     */
    void createParty (PartyConfig config, ResultListener rl);

    /**
     * Joins the given party, which must be open. Sends a HostedNodelet back.
     *
     * Note that while the listener won't return until the party has been sucessfully created
     * and hosted on the server, the client still needs to connect and subscribe before any
     * operations will be successful.
     */
    void joinParty (int partyId, ResultListener rl);
}
