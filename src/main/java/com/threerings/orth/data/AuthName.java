//
// $Id: AuthName.java 19318 2010-09-28 22:24:03Z zell $

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

    protected int _id;
}
