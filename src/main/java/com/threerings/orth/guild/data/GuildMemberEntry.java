//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.guild.data;

import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.data.PlayerEntry;

public class GuildMemberEntry extends PlayerEntry
{
    public GuildRank rank;

    public GuildMemberEntry (VizPlayerName name, GuildRank rank)
    {
        super(name);
        this.rank = rank;
    }

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

    /**
     * Creates a new guild member entry for the given player and status. The photo will be null.
     * TODO: callers of this will need to worry about the photo when those are implemented.
     */
    public static GuildMemberEntry fromOrthName (OrthName playerName, GuildRank rank)
    {
        MediaDesc photo = null; // TODO
        return new GuildMemberEntry(new VizPlayerName(playerName, photo), rank);
    }
}
