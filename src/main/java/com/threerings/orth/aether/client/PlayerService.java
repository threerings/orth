//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.client;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.presents.client.InvocationService;

/**
 * Requests from an Orth client to the Aether server related to their PlayerObject.
 */
public interface PlayerService extends InvocationService
{
    /**
     * Lets the server know we are now ready to get our logon notifications.
     */
    void dispatchDeferredNotifications ();

    /**
     * Invites the specified player to follow the caller. Passing 0 for the playerId will clear all
     * of the caller's followers.
     */
    void inviteToFollow (int playerId, InvocationListener listener);

    /**
     * Requests to follow the specified player who must have previously issued an invitation to the
     * caller to follow them. Passing 0 for playerId will clear the caller's following status.
     */
    void followPlayer (int playerId, InvocationListener listener);

    /**
     * Removes a player from the caller's list of followers. Passing 0 for playerId will clear all
     * the caller's followers.
     */
    void ditchFollower (int playerId, InvocationListener listener);

    /**
     * Set the avatar in use by this user.
     */
    void setAvatar (int avatarId, ConfirmListener listener);

    /**
     * Creates a new guild if this player doesn't already have one. If the guild creation is
     * successful, the {@link PlayerObject#guild} member will be set. Otherwise, the listener
     * will be notified of the failure.
     */
    void createGuild (String name, InvocationListener listener);

    /**
     * Accepts a previously sent guild invitation. The sender must be in the guild and must have
     * sent the invite using {@link com.threerings.orth.guild.client.GuildService#sendInvite()
     * sendInvite}. The guildId is not technically needed but may help avoid the edge case where
     * the sender has changed guilds just after sending the invitation.
     */
    void acceptGuildInvite (int senderId, int guildId, InvocationListener listener);
}
