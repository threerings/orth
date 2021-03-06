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

    public GuildMemberEntry (PlayerName name, GuildName guild, GuildRank rank, Whereabouts abouts)
    {
        super(name, guild, abouts);

        this.rank = rank;
    }

    public boolean isOfficer ()
    {
        return rank == GuildRank.OFFICER;
    }

    @Override
    public GuildMemberEntry clone ()
    {
        return (GuildMemberEntry)super.clone();
    }
}
