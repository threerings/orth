//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.locus.client {

import com.threerings.presents.client.InvocationService_InvocationListener;

import com.threerings.orth.locus.data.HostedLocus;

/**
 * An ActionScript version of the Java LocusService_LocusMaterializationListener interface.
 */
public interface LocusService_LocusMaterializationListener
    extends InvocationService_InvocationListener
{
    // from Java LocusService_LocusMaterializationListener
    function locusMaterialized (arg1 :HostedLocus) :void
}
}
