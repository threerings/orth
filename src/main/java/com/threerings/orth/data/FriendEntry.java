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
    /** The status of the friend's connection. */
    public Whereabouts status;

    /**
     * Creates a new offline friend entry for the given player id and name. The status
     * message will be null.
     */
    public static FriendEntry offline (int id, String name)
    {
        return new FriendEntry(new PlayerName(name, id), Whereabouts.OFFLINE);
    }

    /** Mr. Constructor. */
    public FriendEntry (PlayerName name, Whereabouts status)
    {
        super(name);
        this.status = status;
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
