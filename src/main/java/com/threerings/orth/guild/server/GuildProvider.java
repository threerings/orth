//
// $Id$

package com.threerings.orth.guild.server;

import javax.annotation.Generated;

import com.threerings.orth.guild.client.GuildService;
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
     * Handles a {@link GuildService#sendInvite} request.
     */
    void sendInvite (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;
}
