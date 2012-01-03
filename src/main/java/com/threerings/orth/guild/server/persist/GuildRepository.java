//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.server.persist;

import java.util.List;

import com.threerings.orth.guild.data.GuildRank;

/**
 * Database abstraction for access to guilds.
 */
public interface GuildRepository
{
    /**
     * Gets the id of the guild that the given player belongs to. Zero for none.
     */
    int getGuildId (int playerId);

    /**
     * Gets the guild record for the given guild id.
     */
    GuildRecord getGuild (int guildId);

    /**
     * Gets the members of the guild with the given guild id.
     */
    List<GuildMemberRecord> getGuildMembers (int guildId);

    /**
     * Creates a new guild with the given name and first officer.
     */
    GuildRecord createGuild (String name, int creatorId);

    /**
     * Removes the guild of the given id, if it is empty.
     * @throws Exception if guild is not empty.
     */
    void removeEmptyGuild (int guildId);

    /**
     * Adds a member to a guild with the given rank.
     */
    void addMember (int guildId, int playerId, GuildRank rank);

    /**
     * Removes a member from a guild.
     * @throws Exception if the member is not in the guild
     */
    void removeMember (int guildId, int playerId);

    /**
     * Updates the rank of a member.
     * @throws Exception if the player is not in the guild.
     */
    void updateMember (int guildId, int playerId, GuildRank rank);
}
