//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data.where;

/**
 * Indicates that the player is offline.
 */
public class Online extends Whereabouts
{
    @Override public String getDescription ()
    {
        return "Online";
    }

    @Override public boolean isOnline ()
    {
        return true;
    }

    @Override public boolean equals (Object other)
    {
        return other instanceof com.threerings.orth.data.where.Online;
    }

    @Override public int hashCode ()
    {
        return 0;
    }

    @Override public String toString ()
    {
        return "[Online]";
    }
}
