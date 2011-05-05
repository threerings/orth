//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.party.client;

import com.threerings.presents.client.InvocationService;

/**
 * Provides party services accessed via a world session.
 */
public interface PartyBoardService extends InvocationService
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
     * Retrieve a list of parties. Replies with a List<PartyBoardInfo>.
     */
    void getPartyBoard (byte mode, ResultListener rl);

    /**
     * Locates the specified party in the wide-Whirled.
     */
    void locateParty (int partyId, JoinListener jl);

    /**
     * Creates a new party with the requester as its leader.
     */
    void createParty (String name, boolean inviteAllFriends, JoinListener jl);

    /**
     * Retrieve detailed information on a party. Replies with a PartyDetail object.
     */
    void getPartyDetail (int partyId, ResultListener rl);
}
