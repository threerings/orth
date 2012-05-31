//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.orth.locus.data.LocusAuthName;

/**
 * A {@link LocusAuthName} that signals the server that we are logging into the room services.
 */
public class RoomAuthName extends LocusAuthName
{
    /**
     * Creates an instance that can be used as a DSet key.
     */
    public static RoomAuthName makeKey (int playerId)
    {
        return new RoomAuthName("", playerId);
    }

    // for instantiation
    public RoomAuthName (String accountName, int playerId)
    {
        super(accountName, playerId);
    }
}
