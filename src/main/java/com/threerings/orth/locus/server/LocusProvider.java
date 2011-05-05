//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.locus.server;

import javax.annotation.Generated;

import com.threerings.orth.locus.client.LocusService;
import com.threerings.orth.locus.data.Locus;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link LocusService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from LocusService.java.")
public interface LocusProvider extends InvocationProvider
{
    /**
     * Handles a {@link LocusService#materializeLocus} request.
     */
    void materializeLocus (ClientObject caller, Locus arg1, LocusService.LocusMaterializationListener arg2)
        throws InvocationException;
}
