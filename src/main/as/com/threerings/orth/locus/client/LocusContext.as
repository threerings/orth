//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.locus.client {
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.locus.data.Locus;

/**
 * The shared functionality, on top of PresentsContext, that any location implementation
 * in the Orth framework must support.
 */
public interface LocusContext
    extends PresentsContext
{
    /** For convenience, return our current display name. */
    function get myName () :PlayerName;

    /** For convenience, return {@link #getClient} as a {@link LocusClient}. */
    function get locusClient () :LocusClient;

    /**
     * Optionally do anything needed to prepare the client for connecting to the given locus.
     * This can be an asynchronous operation -- e.g. waiting for a party or guild connection
     * to complete.
     *
     * Return false to let the connection proceed automatically. Return true if you wish to
     * interject your own asynchronous activities, in which case it is your responsibility to
     * execute success, without arguments, if the connection should continue, or fail, with
     * an optional helpful error message, if it should not.
     */
    function prepareForConnection (locus :HostedLocus, success :Function, fail :Function) :Boolean;

    /**
     * Given the precondition that our locus client is logged onto the correct server and
     * that the given place is guaranteed to be resolved on it, request a move into the place.
     */
    function go (locus :Locus) :void;
}
}
