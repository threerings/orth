//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.locus.data;

import com.google.common.collect.ComparisonChain;

import com.threerings.util.Name;

import com.threerings.orth.data.AuthName;

public class LocusAuthName extends AuthName
{
    /**
     * Creates an instance that can be used as a DSet key.
     */
    public static LocusAuthName makeKey (int playerId)
    {
        return new LocusAuthName("", playerId);
    }

    /**
     * Creates a name for the member with the supplied account name and id.
     */
    public LocusAuthName (String accountName, int id)
    {
        super(accountName, id);
    }

    @Override public boolean equals (Object other)
    {
        // LocusAuthName is different from AuthName in that subclasses can be equal()
        return other != null && other instanceof LocusAuthName &&
            (((AuthName)other).getId() == getId());
    }

    @Override // from Name
    public int compareTo (Name o)
    {
        return ComparisonChain.start().
            compare(true, (o instanceof LocusAuthName)).
            compare(getId(), ((AuthName)o).getId()).result();
    }

}
