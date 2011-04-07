package com.threerings.orth.guild.data;

import com.threerings.orth.nodelet.data.Nodelet;

public class GuildNodelet extends Nodelet
{
    public int guildId;

    public GuildNodelet (int guildId)
    {
        this.guildId = guildId;
    }

    public int getId ()
    {
        return guildId;
    }
}
