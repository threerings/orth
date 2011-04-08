/**
 * 
 */
package com.threerings.orth.guild.server.persist;

import java.util.Date;

import com.threerings.orth.guild.data.GuildRank;

public interface GuildMemberRecord
{
    int getPlayerId ();
    Date getDateJoined ();
    GuildRank getRank ();
}
