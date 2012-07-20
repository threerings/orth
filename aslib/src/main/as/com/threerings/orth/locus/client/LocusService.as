//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.locus.client {

import com.threerings.presents.client.InvocationService;

import com.threerings.orth.locus.data.Locus;

/**
 * An ActionScript version of the Java LocusService interface.
 */
public interface LocusService extends InvocationService
{
    // from Java interface LocusService
    function materializeLocus (arg1 :Locus, arg2 :LocusService_LocusMaterializationListener) :void;
}
}
