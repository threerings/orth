//
// $Id$

package com.threerings.orth.world.data;

import com.threerings.io.Streamable;

/**
 * The base type for a specification of a place, used both to instruct the Orth system to
 * host/instantiate the place and for a peer to announce it's hosting it.
 */
public interface PlaceKey extends Comparable<PlaceKey>, Streamable
{
    /** A short, opaque string uniquely identifying what type of place this is. */
    public String getPlaceType ();

    /** Construct a type-appropriate {@link OrthPlace} object, given a hosting peer. */
    public OrthPlace toPlace (String hostingPeer);
}
