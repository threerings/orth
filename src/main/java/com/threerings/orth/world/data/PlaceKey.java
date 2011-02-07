//
// $Id$

package com.threerings.orth.world.data;

import com.threerings.io.SimpleStreamableObject;

/**
 * The base type for a specification of a place, used both to instruct the Orth system to
 * host/instantiate the place and for a peer to announce it's hosting it.
 */
public abstract class PlaceKey extends SimpleStreamableObject
    implements Comparable<PlaceKey>
{
    /** A short, opaque string uniquely identifying what type of place this is. */
    public abstract String getPlaceType ();

    @Override final public int compareTo (PlaceKey other)
    {
        int byType = getPlaceType().compareTo(other.getPlaceType());
        return (byType != 0) ? byType : compareWithinType(other);
    }

    /** Compare this object to another, with the knowledge that it's of the same type. */
    protected abstract int compareWithinType (PlaceKey other);
}
