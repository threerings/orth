//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.guild.server;

import javax.annotation.Generated;

import com.threerings.orth.guild.client.GuildService;
import com.threerings.orth.guild.data.GuildRank;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link GuildService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from GuildService.java.")
public interface GuildProvider extends InvocationProvider
{
    /**
     * Handles a {@link GuildService#disband} request.
     */
    void disband (ClientObject caller, InvocationService.InvocationListener arg1)
        throws InvocationException;

    /**
     * Handles a {@link GuildService#leave} request.
     */
    void leave (ClientObject caller, InvocationService.InvocationListener arg1)
        throws InvocationException;

    /**
     * Handles a {@link GuildService#remove} request.
     */
    void remove (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link GuildService#sendInvite} request.
     */
    void sendInvite (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link GuildService#updateRank} request.
     */
    void updateRank (ClientObject caller, int arg1, GuildRank arg2, InvocationService.InvocationListener arg3)
        throws InvocationException;
}
