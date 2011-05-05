//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.locus.client;

import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.presents.client.InvocationService;

public interface LocusService
    extends InvocationService
{
    interface LocusMaterializationListener extends InvocationListener
    {
        void locusMaterialized (HostedNodelet locus);
    }

    void materializeLocus (Locus locus, LocusMaterializationListener listener);
}
