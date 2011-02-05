//
// $Id$

package com.threerings.orth.world.data {

import com.threerings.io.Streamable;

/**
 * The base type for a specification of a place, used both to instruct the Orth system to
 * host/instantiate the place and for a peer to announce it's hosting it.
 */
public interface PlaceKey extends Streamable
{
    /** A short, opaque string uniquely identifying what type of place this is. */
    function getPlaceType () :String;
}
}
