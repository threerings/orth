//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.party.client.PartyService;
import com.threerings.orth.party.data.PartierObject;

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
    void assignLeader (PartierObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#bootPlayer} request.
     */
    void bootPlayer (PartierObject caller, int arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#invitePlayer} request.
     */
    void invitePlayer (PartierObject caller, PlayerName arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#moveParty} request.
     */
    void moveParty (PartierObject caller, HostedLocus arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#updateDisband} request.
     */
    void updateDisband (PartierObject caller, boolean arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#updateRecruitment} request.
     */
    void updateRecruitment (PartierObject caller, byte arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyService#updateStatus} request.
     */
    void updateStatus (PartierObject caller, String arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;
}
