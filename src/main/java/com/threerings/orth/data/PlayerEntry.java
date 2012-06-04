//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.google.common.base.Function;
import com.google.inject.Inject;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.dobj.DSet;

import com.threerings.orth.data.where.Whereabouts;
import com.threerings.orth.guild.data.GuildName;

public class PlayerEntry extends SimpleStreamableObject
    implements /* IsSerializable, */ DSet.Entry, Cloneable
{
    public static Function<PlayerEntry, PlayerName> NAME = new Function<PlayerEntry, PlayerName>() {
        @Override public PlayerName apply (PlayerEntry entry) {
            return entry.name;
        }
    };
    
    /** The display name of the friend. */
    public PlayerName name;

    /** The name of the guild the player is in, or null. */
    public GuildName guild;

    /** The status of the friend's connection. */
    public Whereabouts whereabouts;

    @Inject
    public PlayerEntry ()
    {
    }

    public PlayerEntry (PlayerName name, GuildName guild, Whereabouts status)
    {
        this.name = name;
        this.guild = guild;
        this.whereabouts = status;
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
