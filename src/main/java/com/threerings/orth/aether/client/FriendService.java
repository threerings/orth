//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.client;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.presents.client.InvocationService;

/**
 * Requests from an Orth client to the Aether server related to their PlayerObject's friends.
 */
public interface FriendService
    extends InvocationService
{
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
}
