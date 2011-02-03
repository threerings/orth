//
// $Id$

package com.threerings.orth.party.data;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.presents.dobj.DSet;

/**
 * Contains basic information on the current party of a player on a peer.
 */
public class MemberParty extends SimpleStreamableObject
    implements DSet.Entry
{
    /** The id of the player. */
    public Integer playerId;

    /** Their party id. */
    public int partyId;

    /** Suitable for deserialization. */
    public MemberParty ()
    {
    }

    /**
     * Constructor.
     */
    public MemberParty (Integer playerId, int partyId)
    {
        this.playerId = playerId;
        this.partyId = partyId;
    }

    // from DSet.Entry
    public Comparable<?> getKey ()
    {
        return playerId;
    }
}
