//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.peer.data;

import com.threerings.presents.peer.data.ClientInfo;

import com.threerings.orth.aether.data.PlayerName;
/**
 * Contains information on a player logged into one of our peer servers.
 */
public class OrthClientInfo extends ClientInfo
{
    public PlayerName playerName;

    /** Returns this member's unique identifier. */
    public int getMemberId ()
    {
        return playerName.getId();
    }
}
