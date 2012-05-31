//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.locus.client;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.locus.data.Locus;

public interface LocusService
    extends InvocationService<AetherClientObject>
{
    interface LocusMaterializationListener extends InvocationListener
    {
        void locusMaterialized (HostedLocus locus);
    }

    void materializeLocus (Locus locus, LocusMaterializationListener listener);
}
