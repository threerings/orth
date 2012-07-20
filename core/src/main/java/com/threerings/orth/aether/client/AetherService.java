//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client;

import com.threerings.presents.client.InvocationService;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.guild.client.GuildService;

/**
 * Requests from an Orth client to the Aether server related to their PlayerObject.
 */
public interface AetherService extends InvocationService<AetherClientObject>
{
    /**
     * Creates a new guild if this player doesn't already have one. If the guild creation is
     * successful, the {@link AetherClientObject#guild} member will be set. Otherwise, the listener
     * will be notified of the failure.
     */
    void createGuild (String name, ConfirmListener listener);

    /**
     * Accepts a previously sent guild invitation. The sender must be in the guild and must have
     * sent the invite using {@link GuildService#sendInvite(int, InvocationService.InvocationListener)}.
     * The guildId is not technically needed but may help avoid the edge case where
     * the sender has changed guilds just after sending the invitation.
     */
    void acceptGuildInvite (int senderId, int guildId, InvocationListener listener);
}
