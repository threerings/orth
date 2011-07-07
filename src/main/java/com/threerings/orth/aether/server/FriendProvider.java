//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

import com.threerings.orth.aether.client.FriendService;
import com.threerings.orth.aether.data.AetherClientObject;

/**
 * Defines the server-side of the {@link FriendService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from FriendService.java.")
public interface FriendProvider extends InvocationProvider
{
    /**
     * Handles a {@link FriendService#acceptFriendshipRequest} request.
     */
    void acceptFriendshipRequest (AetherClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link FriendService#requestFriendship} request.
     */
    void requestFriendship (AetherClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;
}
