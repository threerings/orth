package com.threerings.orth.guild.server.persist;

import java.util.Date;
import java.util.Set;

import com.threerings.orth.guild.data.GuildRank;

public interface GuildRecord
{
    public interface Member
    {
        int getPlayerId ();
        Date getDateJoined ();
        GuildRank getRank ();
    }

    int getGuildId ();
    String getName ();
    Set<Member> getMembers ();
}
