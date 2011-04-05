package com.threerings.orth.guild.data;

import com.threerings.orth.locus.data.Locus;

public class GuildLocus extends Locus
{
    public int guildId;

    public GuildLocus (int guildId)
    {
        this.guildId = guildId;
    }

    public int getId ()
    {
        return guildId;
    }
}
