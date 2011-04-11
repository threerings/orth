package com.threerings.orth.guild.data;

import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.data.PlayerEntry;

public class GuildMemberEntry extends PlayerEntry
{
    public GuildRank rank;

    public GuildMemberEntry (VizPlayerName name, GuildRank rank)
    {
        super(name);
        this.rank = rank;
    }
}
