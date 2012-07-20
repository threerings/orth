//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

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
        if (other == null || !(other instanceof AuthName)) {
            return false;
        }
        AuthName aName = (AuthName) other;
        return getDiscriminator().equals(aName.getDiscriminator()) && getId() == aName.getId();
    }

    public String getDiscriminator ()
    {
        return getClass().getName();
    }

    @Override // from Name
    public int compareTo (Name o)
    {
        String oClass = (o instanceof AuthName) ?
            ((AuthName) o).getDiscriminator() : o.getClass().getName();
        return ComparisonChain.start()
            .compare(getDiscriminator(), oClass)
            .compare(getId(), ((AuthName) o).getId()).result();
    }

    protected int _id;
}
