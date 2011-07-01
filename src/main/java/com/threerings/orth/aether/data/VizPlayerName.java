//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.data.OrthName;

public class VizPlayerName extends OrthName
{
    // We need a no-arg constructor as we have multiple arg'd constructors
    public VizPlayerName ()
    {
        super(null, 0);
    }

    public VizPlayerName (String displayName, int playerId, MediaDesc photo)
    {
        super(displayName, playerId);
        _photo = photo;
    }

    public VizPlayerName (OrthName name, MediaDesc photo)
    {
        this(name.toString(), name.getId(), photo);
    }

    public MediaDesc getPhoto ()
    {
        return _photo;
    }

    public OrthName toOrthName()
    {
        return new OrthName(toString(), getId());
    }

    /** This player's profile photo. */
    protected MediaDesc _photo;
}
