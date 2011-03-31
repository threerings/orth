//
// $Id: $

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
     * Requests that the specified player be added to the local player's friends list. A failure
     * message will be sent if the other player is offline. No return notification is sent if the
     * player ignores the request. If the other player accepts the request, the requester's
     * {@link PlayerObject#friends} will be updated.
     */
    void requestFriendship (int playerId, InvocationListener listener);

    /**
     * Accepts a previously sent friend request notification. If the player is offline, the request
     * will fail. If no previous request was sent, an error will be logged on the server and the
     * request will fail. Othwerise, the request should succeed and both players will have their
     * {@link PlayerObject#friends} updated.
     */
    void acceptFriendshipRequest (int senderId, InvocationListener listener);

    /**
     * Set the avatar in use by this user.
     */
    void setAvatar (int avatarId, ConfirmListener listener);
}
