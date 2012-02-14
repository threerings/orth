//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.threerings.orth.data.where.Whereabouts;
import com.threerings.orth.guild.data.GuildName;

/**
 * Represents a friend connection.
 */
public class FriendEntry extends PlayerEntry
{
    /** Mr. Constructor. */
    public FriendEntry (PlayerName name, GuildName guild, Whereabouts status)
    {
        super(name, guild, status);
    }

    /** Copies this friend entry. */
    @Override
    public FriendEntry clone ()
    {
        try {
            return (FriendEntry)super.clone();
        } catch (CloneNotSupportedException e) {
            throw new AssertionError(e);
        }
    }
}
