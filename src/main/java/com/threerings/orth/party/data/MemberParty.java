//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

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
    public int playerId;

    /** Their party id. */
    public int partyId;

    /** Suitable for deserialization. */
    public MemberParty ()
    {
    }

    /**
     * Constructor.
     */
    public MemberParty (int playerId, int partyId)
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
