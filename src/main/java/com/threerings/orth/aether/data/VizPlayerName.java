//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import com.threerings.orth.data.MediaDesc;

public class VizPlayerName extends PlayerName
{
    /** For unserialization. */
    public VizPlayerName ()
    {
        super(null, 0);
    }

    /**
     * Creates a new name with the supplied data.
     */
    public VizPlayerName (String displayName, int playerId, MediaDesc photo)
    {
        super(displayName, playerId);
        _photo = photo;
    }

    public VizPlayerName (PlayerName name, MediaDesc photo)
    {
        super(name.toString(), name.getId());
        _photo = photo;
    }

    /**
     * Returns a guaranteed plain {@link PlayerName} variant of this name.
     */
    @Override
    public PlayerName toPlayerName ()
    {
        return new PlayerName(_name, _id);
    }

    /**
     * Returns this player's photo.
     */
    public MediaDesc getPhoto ()
    {
        return _photo;
    }

    /** This player's profile photo. */
    protected MediaDesc _photo;
}
