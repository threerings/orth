//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data.where;

/**
 * Indicates that the player is offline.
 */
public class Offline extends Whereabouts
{
    @Override public String getDescription ()
    {
        return "Offline";
    }

    @Override public boolean isOnline ()
    {
        return false;
    }

    @Override public boolean equals (Object other)
    {
        return other instanceof com.threerings.orth.data.where.Offline;
    }

    @Override public int hashCode ()
    {
        return 0;
    }

    @Override public String toString ()
    {
        return "[Offline]";
    }
}
