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
    /**
     * Defines the key for publishing a nodelet. 
     */
    public interface Publishable
    {
        /**
         * Gets the key of the nodelet.
         */
        Comparable<?> getKey ();
    }

    // subclasses should override this, but this fallback works for Publishable nodelets
    public boolean equals (Object other)
    {
        if (this instanceof Publishable) {
            return other != null && other.getClass() == getClass() &&
                ((Publishable)this).getKey().equals(((Publishable)other).getKey());
        }
        return super.equals(other);
    }

    // subclasses should override this, but this fallback works for Publishable nodelets
    public int hashCode ()
    {
        if (this instanceof Publishable) {
            return ((Publishable)this).getKey().hashCode();
        }
        return super.hashCode();
    }

    /**
     * Returns the key if this nodelet is {@link #Publishable}, otherwise null.
     */
    public Comparable<?> getPublishableKey ()
    {
        if (this instanceof Publishable) {
            return ((Publishable)this).getKey();
        }
        return null;
    }

    /**
     * Returns the key if this nodelet is {@link #Publishable}, otherwise fails to cast.
     */
    public Comparable<?> requireKey ()
    {
        return ((Publishable)this).getKey();
    }
}
