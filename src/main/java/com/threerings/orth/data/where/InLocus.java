//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data.where;

import com.google.common.base.Objects;

import com.threerings.orth.locus.data.Locus;

public class InLocus extends Whereabouts
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
