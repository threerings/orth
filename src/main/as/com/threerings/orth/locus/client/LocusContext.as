//
// $Id: $

package com.threerings.orth.locus.client {
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.locus.data.Locus;

/**
 * The shared functionality, on top of PresentsContext, that any location implementation
 * in the Orth framework must support.
 */
public interface LocusContext
    extends PresentsContext
{
    /** Will be called immediately following construction; set up dependencies here. */
    function initDirectors () :void;

    /** For convenience, return our current display name. */
    function getMyName () :PlayerName;

    /** For convenience, return {@link #getClient} as a {@link LocusClient}. */
    function getLocusClient () :LocusClient;

    /**
     * Given the precondition that our locus client is logged onto the correct server and
     * that the given place is guaranteed to be resolved on it, request a move into the place.
     */
    function go (locus :Locus) :void;
}
}