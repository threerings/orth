//
// $Id$

package com.threerings.orth.room.data;

import com.threerings.orth.data.AuthName;

/**
 * An {@link AuthName} that signals the server that we are logging into the room services.
 */
public class RoomAuthName extends AuthName
{
    // for instantiation
    public RoomAuthName (String accountName, int playerId)
    {
        super(accountName, playerId);
    }
}
