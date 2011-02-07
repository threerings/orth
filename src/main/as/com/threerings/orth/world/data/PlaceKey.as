//
// $Id$

package com.threerings.orth.world.data {

import com.threerings.io.SimpleStreamableObject;

/**
 * The base type for a specification of a place, used both to instruct the Orth system to
 * host/instantiate the place and for a peer to announce it's hosting it.
 */
public class PlaceKey extends SimpleStreamableObject
{
    /** A short, opaque string uniquely identifying what type of place this is. */
    public function getPlaceType () :String
    {
        throw new Error("abstract");
    }
}
}
