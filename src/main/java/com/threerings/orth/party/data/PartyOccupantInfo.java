//
// $Id$

package com.threerings.orth.party.data;

/**
 * An OccupantInfo stuffed into PartyPlaceObjects occupied
 * by partiers.
 */
public interface PartyOccupantInfo
{
    /**
     * Get the partyId of this occupant.
     */
    int getPartyId ();

    /**
     * Update the set party id, return true if a change was made.
     */
    boolean updatePartyId (int partyId);
}
