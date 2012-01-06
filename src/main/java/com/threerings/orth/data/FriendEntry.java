//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

/**
 * Represents a friend connection.
 */
public class FriendEntry extends PlayerEntry
{
    public enum Status
    {
        OFFLINE, ONLINE
    }

    /** The status of the friend's connection. */
    public Status status;

    /** The player's self-designated status (not yet implemented). */
    public String statusMessage;

    /**
     * Creates a new offline friend entry for the given player id and name. The status
     * message will be null.
     */
    public static FriendEntry offline (int id, String name)
    {
        String statusMessage = null; // TODO
        return new FriendEntry(new PlayerName(name, id), Status.OFFLINE, statusMessage);
    }

    /**
     * Creates a new friend entry for the given player and status. The status message
     * will be null.
     */
    public static FriendEntry fromOrthName (PlayerName playerName, Status status)
    {
        String statusMessage = null; // TODO
        return new FriendEntry(playerName, status, statusMessage);
    }

    /** Mr. Constructor. */
    public FriendEntry (PlayerName name, Status status, String statusMessage)
    {
        super(name);
        this.status = status;
        this.statusMessage = statusMessage;
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
