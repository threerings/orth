//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.locus.data;

import com.threerings.orth.data.AuthName;

/**
 * LocusAuthName has no current purpose, other than to mark Locus connections.
 */
public abstract class LocusAuthName extends AuthName
{
    /**
     * Creates a name for the member with the supplied account name and id.
     */
    public LocusAuthName (String accountName, int id)
    {
        super(accountName, id);
    }
}
