//
// $Id: $

package com.threerings.orth.aether.client;

import com.threerings.presents.client.InvocationService;

/**
 * Requests from an Orth client to the Aether server related to their PlayerObject.
 */
public interface PlayerService extends InvocationService
{
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
}
