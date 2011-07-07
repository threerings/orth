//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

import com.threerings.orth.room.client.PetService;

/**
 * Defines the server-side of the {@link PetService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PetService.java.")
public interface PetProvider extends InvocationProvider
{
    /**
     * Handles a {@link PetService#callPet} request.
     */
    void callPet (ClientObject caller, int arg1, InvocationService.ConfirmListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PetService#orderPet} request.
     */
    void orderPet (ClientObject caller, int arg1, int arg2, InvocationService.ConfirmListener arg3)
        throws InvocationException;

    /**
     * Handles a {@link PetService#sendChat} request.
     */
    void sendChat (ClientObject caller, int arg1, int arg2, String arg3, InvocationService.ConfirmListener arg4)
        throws InvocationException;
}
