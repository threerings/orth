//
// $Id: PartyPeep.java 13690 2008-12-05 03:54:36Z ray $

package com.threerings.orth.party.data;

import com.threerings.orth.data.PlayerEntry;
import com.threerings.orth.data.VizOrthName;

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

    /** Suitable for deserialization. */
    public PartyPeep ()
    {
    }

    /** Mr. Constructor. */
    public PartyPeep (VizOrthName name, int joinOrder)
    {
    	super(name);
        this.joinOrder = joinOrder;
    }

    @Override
    public String toString ()
    {
        return "PartyPeep[" + name + "]";
    }
}
