//
// $Id$

package com.threerings.orth.world.server;

import javax.annotation.Generated;

import com.threerings.orth.world.client.WorldService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link WorldService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from WorldService.java.")
public interface WorldProvider extends InvocationProvider
{
    /**
     * Handles a {@link WorldService#ditchFollower} request.
     */
    void ditchFollower (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WorldService#followMember} request.
     */
    void followMember (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WorldService#inviteToFollow} request.
     */
    void inviteToFollow (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link WorldService#setAvatar} request.
     */
    void setAvatar (ClientObject caller, int arg1, InvocationService.ConfirmListener arg2)
        throws InvocationException;
}
