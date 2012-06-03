//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.peer.data;

import java.util.List;
import java.util.Set;

import com.threerings.presents.peer.data.ClientInfo;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.data.where.Whereabouts;
import com.threerings.orth.guild.data.GuildName;

/**
 * Contains information on a player logged into one of our peer servers.
 */
public class OrthClientInfo extends ClientInfo
{
    /** For aether clients, the player's visible name. */
    public PlayerName visibleName;

    /** For aether clients, what guild we're in, or null. */
    public GuildName guild;

    /** All the players on our ignore list. */
    public Set<Integer> ignoring;

    /**
     *  Where is this player? Any client type can theoretically contribute data, but at the
     *  moment aether clients always have 'Offline' or 'Online' here, and Locus connections
     *  will typically have either 'Offline' or 'InLocus', the latter being perhaps the
     *  more interesting data.
     */
    public Whereabouts whereabouts;
}
