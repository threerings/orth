//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import java.util.List;

/**
 * A more detailed representation of a party that a player may request prior to joining.
 */
public class PartyDetail extends PartyBoardInfo
{
    /** The people in this party. */
    public List<PartyPeep> peeps;

    public PartyDetail (PartySummary summary, PartyInfo info, List<PartyPeep> peeps)
    {
        super(summary, info);
        this.peeps = peeps;
    }
}
