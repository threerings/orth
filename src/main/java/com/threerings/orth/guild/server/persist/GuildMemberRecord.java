//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

/**
 *
 */
package com.threerings.orth.guild.server.persist;

import java.util.Date;

import com.google.common.base.Function;
import com.threerings.orth.guild.data.GuildRank;

/**
 * Abstraction of persistent guild membership data for orth.
 */
public interface GuildMemberRecord
{
    /** Function to extract the player id from a guild member record. */
    public static final Function<GuildMemberRecord, Integer> TO_PLAYER_ID =
            new Function<GuildMemberRecord, Integer>() {
        public Integer apply (GuildMemberRecord gmrec) {
            return gmrec.getPlayerId();
        }
    };

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
