package com.threerings.orth.guild.server.persist;

import java.util.List;

import com.google.inject.Singleton;

import com.threerings.orth.guild.data.GuildRank;

/**
 * Database abstraction for access to guilds.
 */
@Singleton
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
     * Removes the guild of the given id, if it is empty. Otherwise throws an unchecked exception.
     */
    void removeEmptyGuild (int guildId);

    /**
     * Adds a member to a guild with the given rank.
     */
    void addMember (int guildId, int playerId, GuildRank rank);

    /**
     * Removes a member from a guild.
     */
    void removeMember (int guildId, int playerId);
}
