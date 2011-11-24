//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.google.common.base.Objects;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.util.ActionScript;

import com.threerings.orth.locus.data.Locus;

@ActionScript(omit=true)
public abstract class Whereabouts extends SimpleStreamableObject
{
    /** Indicate the all that's known is that the player is offline. */
    public static final Offline OFFLINE = new Offline();

    /** Indicate the all that's known is that the player is online. */
    public static final Online ONLINE = new Online();

    /**
     * Indicates that the player is offline.
     */
    public static class Offline extends Whereabouts
    {
        @Override public String getDescription ()
        {
            return "m.offline";
        }

        @Override public boolean isOnline ()
        {
            return false;
        }

        @Override public boolean equals (Object other)
        {
            return other instanceof Offline;
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

    /**
     * Indicates that the player is offline.
     */
    public static class Online extends Whereabouts
    {
        @Override public String getDescription ()
        {
            return "m.online";
        }

        @Override public boolean isOnline ()
        {
            return true;
        }

        @Override public boolean equals (Object other)
        {
            return other instanceof Online;
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

    public static class InLocus extends Whereabouts
    {
        public Locus locus;
        public String description;

        public InLocus (Locus locus, String description)
        {
            this.locus = locus;
            this.description = description;
        }

        public Locus getLocus ()
        {
            return locus;
        }

        @Override public String getDescription ()
        {
            return description;
        }

        @Override public boolean isOnline ()
        {
            return true;
        }

        @Override public boolean equals (Object other)
        {
            return other != null && other instanceof InLocus &&
                locus.equals(((InLocus) other).getLocus());
        }

        @Override public int hashCode ()
        {
            return Objects.hashCode(locus);
        }
    }

    /**
     * Returns a translatable description of the player's whereabouts.
     */
    public abstract String getDescription ();

    /**
     * Checks whether the player is online.
     */
    public abstract boolean isOnline ();
}
