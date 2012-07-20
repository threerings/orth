//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.data;

import com.google.common.primitives.Ints;

import com.threerings.util.Name;

import com.threerings.presents.dobj.DSet;

public class GuildName extends Name
    implements DSet.Entry
{
    /**
     * Creates a name instance with the supplied name.
     */
    public GuildName (String name, int id)
    {
        super(name);
        _id = id;
    }

    /**
     * Return the id of this guild
     */
    public int getGuildId ()
    {
        return _id;
    }

    @Override
    public Comparable<?> getKey ()
    {
        return _id;
    }

    @Override // from Name
    public int hashCode ()
    {
        return _id;
    }

    @Override // from Name
    public boolean equals (Object other)
    {
        return (other instanceof GuildName) && (((GuildName) other).getGuildId() == _id);
    }

    @Override // from Name
    public int compareTo (Name o)
    {
        return Ints.compare(_id, ((GuildName) o).getGuildId());
    }

    protected int _id;
}
