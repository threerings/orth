//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import javax.annotation.Generated;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.party.client.PartyService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link PartyService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PartyService.java.")
public interface PartyProvider extends InvocationProvider
{
    /**
     * Handles a {@link PartyService#assignLeader} request.
     */
    void assignLeader (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#bootPlayer} request.
     */
    void bootPlayer (ClientObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#invitePlayer} request.
     */
    void invitePlayer (ClientObject caller, PlayerName arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#moveParty} request.
     */
    void moveParty (ClientObject caller, HostedLocus arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#updateDisband} request.
     */
    void updateDisband (ClientObject caller, boolean arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#updateRecruitment} request.
     */
    void updateRecruitment (ClientObject caller, byte arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#updateStatus} request.
     */
    void updateStatus (ClientObject caller, String arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;
}
