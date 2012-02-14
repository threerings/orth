//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.locus.data;

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

    @Override
    public String getDiscriminator ()
    {
        return LocusAuthName.class.getName();
    }
}
