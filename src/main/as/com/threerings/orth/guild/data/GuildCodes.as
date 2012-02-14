//
// Who - Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.guild.data
{
import com.threerings.presents.data.InvocationCodes;

public class GuildCodes extends InvocationCodes
{
    /** Error thrown when a player is already in a guild. */
    public static const E_PLAYER_ALREADY_IN_GUILD :String = "e.player_already_in_guild";

    /** Error thrown when a player has already been invited. */
    public static const E_INVITE_ALREADY_SENT :String = "e.guild_invite_already_sent";

    /** Error thrown when attempting to disband a group with other members. */
    public static const E_GUILD_HAS_OTHER_MEMBERS :String = "e.guild_has_other_members";

    /** Error thrown when the player tries to create a guild that already exists. */
    public static const E_GUILD_ALREADY_EXISTS :String = "e.guild_already_exists";
}
}
