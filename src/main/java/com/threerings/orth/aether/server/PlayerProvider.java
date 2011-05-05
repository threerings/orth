//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.aether.server;

import javax.annotation.Generated;

import com.threerings.orth.aether.client.PlayerService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link PlayerService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PlayerService.java.")
public interface PlayerProvider extends InvocationProvider
{
    /**
     * Handles a {@link PlayerService#acceptGuildInvite} request.
     */
    void acceptGuildInvite (ClientObject caller, int arg1, int arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;

    /**
     * Handles a {@link PlayerService#createGuild} request.
     */
    void createGuild (ClientObject caller, String arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PlayerService#dispatchDeferredNotifications} request.
     */
    void dispatchDeferredNotifications (ClientObject caller);

    /**
     * Handles a {@link PlayerService#ditchFollower} request.
     */
    void ditchFollower (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PlayerService#followPlayer} request.
     */
    void followPlayer (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PlayerService#inviteToFollow} request.
     */
    void inviteToFollow (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PlayerService#setAvatar} request.
     */
    void setAvatar (ClientObject caller, int arg1, InvocationService.ConfirmListener arg2)
        throws InvocationException;
}
