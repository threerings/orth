//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.data;

import com.threerings.presents.data.InvocationCodes;

/**
 * UI identifiers relating to use of the guild service or guild methods in the player service.
 */
public interface GuildCodes extends InvocationCodes
{
    /** Error thrown when a player is already in a guild. */
    public static final String E_PLAYER_ALREADY_IN_GUILD = "e.player_already_in_guild";

    /** Error thrown when a player has already been invited. */
    public static final String E_INVITE_ALREADY_SENT = "e.guild_invite_already_sent";

    /** Error thrown when attempting to disband a group with other members. */
    public static final String E_GUILD_HAS_OTHER_MEMBERS = "e.guild_has_other_members";

    /** Error thrown when the player tries to create a guild that already exists. */
    public static final String E_GUILD_ALREADY_EXISTS = "e.guild_already_exists";

    /** Error thrown for an unacceptable guild name. */
    public static final String E_BAD_GUILD_NAME = "e.bad_guild_name";
}
