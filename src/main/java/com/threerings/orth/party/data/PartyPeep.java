//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.data.PlayerEntry;

/**
 * Represents a fellow party-goer connection.
 */
public class PartyPeep extends PlayerEntry
{
    /**
     * The order of the partier among all the players who have joined this party. The lower this
     * value, the better priority they have to be auto-assigned leadership.
     */
    public int joinOrder;

    /** Mr. Constructor. */
    public PartyPeep (VizPlayerName name, int joinOrder)
    {
    	super(name);
        this.joinOrder = joinOrder;
    }
}
