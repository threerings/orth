//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.nodelet.data;

import com.threerings.io.SimpleStreamableObject;

/**
 * The base type for an object that is subscribed to simultaneously by multiple players and is
 * hosted on a single server, which each subscriber must connect to. The nodelet is used to
 * instantiate the shared {@code DObject} that players will subscribe to. If the {@link
 * #Publishable} interface is also implemented, then the nodelet may also be used to publish
 * the hosting state to other peers.
 */
public abstract class Nodelet extends SimpleStreamableObject
{
    public boolean equals (Object other)
    {
        return other != null && other.getClass() == getClass()
            && getKey().equals(((Nodelet)other).getKey());
    }

    public int hashCode ()
    {
        return getKey().hashCode();
    }

    public abstract Comparable<?> getKey ();

}
