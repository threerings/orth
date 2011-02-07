//
// $Id$

package com.threerings.orth.peer.data;

import com.google.common.collect.ComparisonChain;

import com.threerings.orth.world.data.PlaceKey;
import com.threerings.presents.dobj.DSet;
import com.threerings.util.ActionScript;

/**
 * Information about a place hosted by a node.
 */
@ActionScript(omit=true)
public class HostedPlace
    implements DSet.Entry, Comparable<HostedPlace>
{
    public PlaceKey key;
    public String name;
    int population;

    /** For deserialization. */
    public HostedPlace ()
    {
    }

    public HostedPlace (PlaceKey key, String name)
    {
        this.key = key;
        this.name = name;
    }

    public Comparable<?> getKey ()
    {
        return this;
    }

    public int compareTo (HostedPlace other)
    {
        return ComparisonChain.start()
            .compare(this.key.getPlaceType(), other.key.getPlaceType())
            .compare(this.key, other.key)
            .result();
    }
}
