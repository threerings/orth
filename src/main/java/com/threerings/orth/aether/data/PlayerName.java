//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import com.threerings.orth.data.OrthName;

public class PlayerName extends OrthName
{
    /**
     * Creates a new name with the supplied data.
     */
    public PlayerName (String displayName, int playerId)
    {
        super(displayName, playerId);
    }

    /**
     * Returns a guaranteed plain {@link PlayerName} variant of this name.
     */
    public PlayerName toPlayerName ()
    {
        return this;
    }
}
