//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.util.ActionScript;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.data.where.Whereabouts;
import com.threerings.orth.guild.data.GuildName;

@ActionScript(omit=true)
public class PeeredPlayerInfo extends SimpleStreamableObject
{
    public AetherAuthName authName;
    public PlayerName visibleName;
    public GuildName guildName;
    public Whereabouts whereabouts;
}
