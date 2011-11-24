//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.google.common.collect.ComparisonChain;

import com.threerings.util.Name;

/**
 * Represents the authentication username for services that derive from orth.
 */
public class AuthName extends Name
{
    /** Creates a name for the member with the supplied account name and id. */
    public AuthName (String accountName, int id)
    {
        super(accountName);
        _id = id;
    }

    /** Returns this session's unique id. */
    public int getId ()
    {
        return _id;
    }

    @Override // from Name
    public int hashCode ()
    {
        return _id;
    }

    @Override // from Name
    public boolean equals (Object other)
    {
        return (other != null) && other.getClass().equals(getClass()) &&
            (((AuthName)other).getId() == getId());
    }

    @Override // from Name
    public int compareTo (Name o)
    {
        return ComparisonChain.start()
            .compare(getClass().getName(), o.getClass().getName())
            .compare(getId(), ((AuthName)o).getId()).result();
    }

    @Override
    public String toString ()
    {
        return "[name=" + super.toString() + ", id=" + _id + "]";
    }

    protected int _id;
}
