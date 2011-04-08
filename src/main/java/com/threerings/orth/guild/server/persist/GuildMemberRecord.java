/**
 * 
 */
package com.threerings.orth.guild.server.persist;

import java.util.Date;

import com.threerings.orth.guild.data.GuildRank;

/**
 * Abstraction of persistent guild membership data for orth.
 */
public interface GuildMemberRecord
{
    /**
     * Gets the id of the player that belongs to the guild.
     */
    int getPlayerId ();

    /**
     * Gets the date the player joined the guild.
     */
    Date getDateJoined ();

    /**
     * Gets the rank of the player in the guild.
     */
    GuildRank getRank ();
}
