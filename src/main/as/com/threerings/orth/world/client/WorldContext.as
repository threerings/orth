//
// $Id: $

package com.threerings.orth.world.client {

import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.world.data.Destination;
import com.threerings.orth.world.data.OrthPlayerBody;

/**
 * The shared functionality, on top of PresentsContext, that any location implementation
 * in the Orth framework must support.
 */
public interface WorldContext
    extends PresentsContext
{
    /** Will be called immediately following construction; set up dependencies here. */
    function initDirectors () :void;

    /** Return the {@link BodyObject} subclass we're inhabiting, or null if we're not logged on. */
    function getPlayerBody () :OrthPlayerBody;

    /** For convenience, return our current display name. */
    function getMyName () :PlayerName;

    /** For convenience, return {@link #getClient} as a {@link WorldClient}. */
    function getWorldClient () :WorldClient;

    /**
     * Given the precondition that our world client is logged onto the correct server and
     * that the given place is guaranteed to be resolved on it, request a move into the place.
     */
    function go (destination :Destination) :void;
}
}
