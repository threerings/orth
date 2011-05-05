//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.party.data;

import com.threerings.orth.data.TokenCredentials;

/**
 * Used to authenticate a party session.
 */
public class PartyCredentials extends TokenCredentials
{
    /**
     * Gets the party id the player wants to access.
     */
    public int getPartyId ()
    {
        return (Integer)object;
    }
}
