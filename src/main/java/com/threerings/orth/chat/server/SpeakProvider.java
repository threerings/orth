//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import javax.annotation.Generated;

import com.threerings.orth.chat.client.SpeakService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link SpeakService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from SpeakService.java.")
public interface SpeakProvider extends InvocationProvider
{
    /**
     * Handles a {@link SpeakService#speak} request.
     */
    void speak (ClientObject caller, String arg1, InvocationService.InvocationListener arg2)
        throws InvocationException;
}
