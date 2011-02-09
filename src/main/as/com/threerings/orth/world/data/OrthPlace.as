//
// $Id$

package com.threerings.orth.world.data {

import com.threerings.io.Streamable;

/**
 * The base type for a peer-qualified, instantiated location that an Orth player can be in.
 */
public interface OrthPlace extends Streamable
{
    /** Returns the peer this place is hosted on. */
    function getPeer () :String;

    /** Returns A short, opaque string uniquely identifying what type of place this is. */
    function getPlaceType () :String;

    /** Returns A short, human-readable description of what place this is. */
    function describePlace () :String;
}
}
