//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.data;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.presents.dobj.DSet;

public class PlayerEntry extends SimpleStreamableObject
    implements /* IsSerializable, */ DSet.Entry, Cloneable
{
    /** The display name of the friend. */
    public VizPlayerName name;

    public PlayerEntry (VizPlayerName name)
    {
        this.name = name;
    }

    public int getPlayerId ()
    {
        return name.getId();
    }

    // from interface DSet.Entry
    public Comparable<?> getKey ()
    {
        return this.name.getKey();
    }

    @Override // from Object
    public int hashCode ()
    {
        return this.name.hashCode();
    }

    @Override // from Object
    public boolean equals (Object other)
    {
        return (other instanceof PlayerEntry) &&
            (this.name.getId() == ((PlayerEntry)other).name.getId());
    }
}
