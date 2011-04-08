package com.threerings.orth.guild.server.persist;

/**
 * Abstraction of persistent guild data for orth.
 */
public interface GuildRecord
{
    /**
     * Gets the unique id of the guild.
     */
    int getGuildId ();

    /**
     * Gets the name of the guild.
     */
    String getName ();
}
