//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.google.inject.Inject;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.dobj.DSet;

import com.threerings.orth.aether.data.VizPlayerName;

public class PlayerEntry extends SimpleStreamableObject
    implements /* IsSerializable, */ DSet.Entry, Cloneable
{
    /** The display name of the friend. */
    public VizPlayerName name;

    @Inject
    public PlayerEntry ()
    {
    }

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
