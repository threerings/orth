//
// $Id: $

package com.threerings.orth.world.client {
import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.util.CrowdContext;
import com.threerings.orth.data.OrthName;

/**
 * The shared functionality, on top of CrowdContext, that any location implementation
 * in the Orth framework must support.
 */
public interface WorldContext
    extends CrowdContext
{
    /** Return the {@link BodyObject} subclass we're inhabiting, or null if we're not logged on. */
    function getBodyObject () :BodyObject;

    /** For convenience, return our current display name. */
    function getMyName () :OrthName;
}
}
