package com.threerings.orth.guild.server.persist;

/**
 * Database abstraction for access to guilds.
 */
public interface GuildRepository
{
    int getGuildId (int playerId);
    GuildRecord getGuild (int guildId);
    GuildRecord createGuild (String name, int creatorId);
}
