//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.orth.locus.data.LocusAuthName;

/**
 * A {@link LocusAuthName} that signals the server that we are logging into the room services.
 */
public class RoomAuthName extends LocusAuthName
{
    // for instantiation
    public RoomAuthName (String accountName, int playerId)
    {
        super(accountName, playerId);
    }
}
