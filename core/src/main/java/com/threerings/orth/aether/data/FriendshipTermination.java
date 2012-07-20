//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.data.PlayerName;

public class FriendshipTermination extends BaseOneToOneComm
{
    public FriendshipTermination (PlayerName from, PlayerName to)
    {
        super(from, to);
    }
}
