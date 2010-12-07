//
// $Id: WorldService.java 18317 2009-10-08 23:12:28Z zell $

package com.threerings.orth.world.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

/**
 * Provides global services to the world client.
 */
public interface WorldService extends InvocationService
{
    /**
     * Invites the specified member to follow the caller. Passing 0 for the memberId will clear all
     * of the caller's followers.
     */
    void inviteToFollow (Client client, int memberId, InvocationListener listener);

    /**
     * Requests to follow the specified member who must have previously issued an invitation to the
     * caller to follow them. Passing 0 for memberId will clear the caller's following status.
     */
    void followMember (Client client, int memberId, InvocationListener listener);

    /**
     * Removes a player from the caller's list of followers. Passing 0 for memberId will clear all
     * the caller's followers.
     */
    void ditchFollower (Client client, int memberId, InvocationListener listener);

    /**
     * Set the avatar in use by this user.
     */
    void setAvatar (Client client, int avatarId, ConfirmListener listener);
}
