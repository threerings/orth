//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.client;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.guild.data.GuildRank;

/**
 * Services for managing a guild.
 */
public interface GuildService extends InvocationService<ClientObject>
{
    /**
     * Invites another player to join the guild. If the invitation is accepted, the target player
     * will have {@link AetherClientObject#guild} and {@link AetherClientObject#guildName}
     * updated and will be added to {@link GuildObject#members}. On failure, the listener will be
     * notified of the error.
     */
    void sendInvite (int playerId, InvocationListener listener);

    /**
     * Sets the rank of a player to a new value. Only {@link GuildRank#OFFICER} callers are allowed
     * to update the rank and an officer's rank cannot be changed. On success, the change will be
     * propagated to the {@link GuildObject#members} set. On failure, the listener will be notified.
     */
    void updateRank (int playerId, GuildRank newRank, InvocationListener listener);

    /**
     * Remove the given member from the guild. This will fail if the caller is not an officer or
     * if the other player is an officer. On success, the change will be propagated to the {@link
     * GuildObject#members} set. On failure, the listener will be notified.
     */
    void remove (int playerId, InvocationListener listener);

    /**
     * Remove the caller from the guild. This will fail if the caller is the sole officer in the
     * guild. On success, the change will be propagated to the {@link GuildObject#members} set. On
     * failure, the listener will be notified.
     */
    void leave (InvocationListener listener);

    /**
     * Delete the guild. This will fail unless the caller is the sole officer in the guild.
     * On success, the manager will shutdown and the object be destroyed. On failure, the listener
     * will be notified.
     */
    void disband (InvocationListener listener);
}
