//
// $Id: $

package com.threerings.orth.world.client {

import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.data.OrthName;
import com.threerings.orth.world.data.OrthPlace;
import com.threerings.orth.world.data.OrthPlayerBody;

/**
 * The shared functionality, on top of PresentsContext, that any location implementation
 * in the Orth framework must support.
 */
public interface WorldContext
    extends PresentsContext
{
    /** Return the {@link BodyObject} subclass we're inhabiting, or null if we're not logged on. */
    function getPlayerBody () :OrthPlayerBody;

    /** For convenience, return our current display name. */
    function getMyName () :OrthName;

    /** For convenience, return {@link #getClient} as a {@link WorldClient}. */
    function getWorldClient () :WorldClient;

    /**
     * Given the precondition that our world client is logged onto the correct server and
     * that the given place is guaranteed to be resolved on it, request a move into the place.
     */
    function gotoPlace (place :OrthPlace) :void;
}
}
