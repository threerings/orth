//
// $Id$

package com.threerings.orth.world.data;

import com.threerings.io.Streamable;

/**
 * The base type for a peer-qualified, instantiated location that an Orth player can be in.
 */
public interface OrthPlace extends Streamable
{
    /** The peer this place is hosted on. */
    public String getPeer ();

    /** A short, opaque string uniquely identifying what type of place this is. */
    public String getPlaceType ();

    /** A short, human-readable description of what place this is. */
    public String describePlace ();
}
