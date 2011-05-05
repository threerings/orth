//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.server.persist;

import com.threerings.orth.aether.data.PlayerName;

/**
 * Just enough information about a player for Orth to do what it needs to do.
 */
public interface OrthPlayerRecord
{
    public PlayerName getPlayerName();
}
