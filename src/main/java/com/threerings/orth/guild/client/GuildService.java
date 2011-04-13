//
// $Id$

package com.threerings.orth.guild.client;

import com.threerings.presents.client.InvocationService;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.guild.data.GuildObject;

/**
 * Services for managing a guild.
 */
public interface GuildService extends InvocationService
{
    /**
     * Invites another player to join the guild. If the invitation is accepted, the target player
     * will have {@link PlayerObject#guild guild} and {@link PlayerObject#guildId guildId} updated
     * and will be added to {@link GuildObject#members}. On failure, the listener will be notified
     * of the error.  
     */
    void sendInvite (int playerId, InvocationListener listener);
}
