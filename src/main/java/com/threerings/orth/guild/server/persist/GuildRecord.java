//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
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
