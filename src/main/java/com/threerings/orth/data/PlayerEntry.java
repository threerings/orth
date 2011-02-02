//
// $Id: PlayerEntry.java 19625 2010-11-24 15:47:54Z zell $

package com.threerings.orth.data;

import com.threerings.presents.dobj.DSet;

import com.google.gwt.user.client.rpc.IsSerializable;

import com.threerings.orth.aether.data.VizPlayerName;

public class PlayerEntry
    implements /* IsSerializable, */ DSet.Entry
{
    /** The display name of the friend. */
    public VizPlayerName name;

    /** Suitable for deserialization. */
    public PlayerEntry ()
    {
    }

    public PlayerEntry (VizPlayerName name)
    {
        this.name = name;
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

    @Override
    public String toString ()
    {
        return "PlayerEntry[" + name + "]";
    }
}
