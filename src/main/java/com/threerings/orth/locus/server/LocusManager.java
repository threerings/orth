//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.locus.server;

import java.util.Map;

import com.google.common.base.Preconditions;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.data.LocusMarshaller;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

@Singleton
public class LocusManager
    implements LocusProvider
{
    @Inject
    public LocusManager (InvocationManager invmgr, Injector injector)
    {
        invmgr.registerProvider(this, LocusMarshaller.class, OrthCodes.LOCUS_GROUP);
    }

    @Override
    public void materializeLocus (ClientObject caller, Locus locus,
            final LocusMaterializationListener listener)
        throws InvocationException
    {
        LocusMaterializer materializer = _materializers.get(locus.getClass());
        Preconditions.checkNotNull(materializer, "No materializer for locus '%s' of class '%s'",
            locus, locus.getClass());
        materializer.materializeLocus(caller, locus, listener);
    }

    @Inject protected Map<Class<?>, LocusMaterializer> _materializers;
}
