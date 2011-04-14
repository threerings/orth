package com.threerings.orth.guild.data;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.data.PlayerEntry;

public class GuildMemberEntry extends PlayerEntry
{
    public GuildRank rank;

    public GuildMemberEntry (VizPlayerName name, GuildRank rank)
    {
        super(name);
        this.rank = rank;
    }

    /**
     * Creates a new guild member entry for the given player and status. The photo will be null.
     * TODO: callers of this will need to worry about the photo when those are implemented.
     */
    public static GuildMemberEntry fromPlayerName (PlayerName playerName, GuildRank rank)
    {
        MediaDesc photo = null; // TODO
        return new GuildMemberEntry(new VizPlayerName(playerName, photo), rank);
    }
}
