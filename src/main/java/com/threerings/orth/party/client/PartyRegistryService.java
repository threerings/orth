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
    /** Provides a response to {@link #createParty} and {@link #locateParty}. */
    public static interface JoinListener extends InvocationListener
    {
        /**
         * Reports the connection info for the Whirled node that is hosting the requested party.
         */
        void foundParty (int partyId, String hostname, int port);
    }

    /**
     * Locates the specified party in the wide-Whirled.
     */
    void locateParty (int partyId, JoinListener jl);

    /**
     * Creates a new party with the requester as its leader.
     */
    void createParty (String name, boolean inviteAllFriends, JoinListener jl);
}
