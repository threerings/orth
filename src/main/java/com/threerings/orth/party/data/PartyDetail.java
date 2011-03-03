//
// $Id$

package com.threerings.orth.party.data;

import java.util.List;

/**
 * A more detailed representation of a party that a player may request prior to joining.
 */
public class PartyDetail extends PartyBoardInfo
{
    /** The people in this party. */
    public List<PartyPeep> peeps;

    /** Suitable for unserialization. */
    public PartyDetail () {}

    /**
     * Construct a party detail.
     */
    public PartyDetail (PartySummary summary, PartyInfo info, List<PartyPeep> peeps)
    {
        super(summary, info);
        this.peeps = peeps;
    }
}
