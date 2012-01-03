//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.data;

import com.threerings.orth.nodelet.data.Nodelet;

public class GuildNodelet extends Nodelet
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
