//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.locus.server;

import com.threerings.presents.data.ClientObject;

import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;

public interface LocusMaterializer
{
    void materializeLocus (ClientObject caller, Locus locus, LocusMaterializationListener listener);
}
