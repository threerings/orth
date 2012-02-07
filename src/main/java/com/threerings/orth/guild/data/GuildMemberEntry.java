//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.data;

import com.threerings.orth.data.PlayerEntry;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.data.where.Whereabouts;

public class GuildMemberEntry extends PlayerEntry
{
    public GuildRank rank;

    public GuildMemberEntry (PlayerName name, GuildRank rank, Whereabouts abouts)
    {
        super(name, abouts);
        this.rank = rank;
    }

    @Override
    public GuildMemberEntry clone ()
    {
        try {
            return (GuildMemberEntry)super.clone();
        } catch (CloneNotSupportedException e) {
            throw new AssertionError(e);
        }
    }

    public boolean isOfficer ()
    {
        return rank == GuildRank.OFFICER;
    }
}
