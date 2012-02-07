//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.threerings.orth.data.where.Whereabouts;

/**
 * Represents a friend connection.
 */
public class FriendEntry extends PlayerEntry
{
    /** Mr. Constructor. */
    public FriendEntry (PlayerName name, Whereabouts status)
    {
        super(name, status);
    }

    /** Copies this friend entry. */
    @Override
    public FriendEntry clone ()
    {
        try {
            return (FriendEntry)super.clone();
        } catch (CloneNotSupportedException e) {
            throw new AssertionError(e);
        }
    }
}
