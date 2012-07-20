//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import com.google.common.base.Predicate;

import com.threerings.orth.data.PlayerEntry;

/**
 * Represents a fellow party-goer connection.
 */
public class PartyPeep extends PlayerEntry
{
    public static Predicate<PartyPeep> DISCONNECTED = new Predicate<PartyPeep>() {
        @Override public boolean apply (PartyPeep peep) {
            return !peep.connected;
        }
    };

    /**
     * The order of the partier among all the players who have joined this party. The lower this
     * value, the better priority they have to be auto-assigned leadership.
     */
    public int joinOrder;

    /**
     * An explicit online/offline boolean. We could sort of use {@link PlayerEntry#whereabouts},
     * but that value has complex connotations, whereas this one specifically refers to the party
     * connection being established.
     */
    public boolean connected;
}
