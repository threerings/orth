package com.threerings.orth.guild.data;

import com.threerings.orth.nodelet.data.Nodelet;

public class GuildNodelet extends Nodelet
    implements Nodelet.Publishable
{
    public int guildId;

    public GuildNodelet (int guildId)
    {
        this.guildId = guildId;
    }

    @Override
    public Comparable<?> getKey ()
    {
        return guildId;
    }
}
