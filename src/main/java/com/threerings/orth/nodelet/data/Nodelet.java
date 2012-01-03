//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.nodelet.data;

import com.threerings.io.SimpleStreamableObject;

/**
 * The base type for an object that is subscribed to simultaneously by multiple players and is
 * hosted on a single server, which each subscriber must connect to. The nodelet is used to
 * instantiate the shared {@code DObject} that players will subscribe to.
 */
public abstract class Nodelet extends SimpleStreamableObject
{
    @Override
    public boolean equals (Object other)
    {
        return other != null && other.getClass() == getClass()
            && getKey().equals(((Nodelet)other).getKey());
    }

    @Override
    public int hashCode ()
    {
        return getKey().hashCode();
    }

    public abstract Comparable<?> getKey ();

}
