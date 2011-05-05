//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.VizPlayerName;

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
     * Creates a new offline friend entry for the given player id and name. The photo and status
     * message will be null.
     * TODO: callers of this will need to worry about photo and status message when those are
     * implemented.
     */
    public static FriendEntry offline (int id, String name)
    {
        MediaDesc photo = null; // TODO
        String statusMessage = null; // TODO
        return new FriendEntry(new VizPlayerName(name, id, photo), Status.OFFLINE, statusMessage);
    }

    /**
     * Creates a new friend entry for the given player and status. The photo and status message
     * will be null.
     * TODO: callers of this will need to worry about photo and status message when those are
     * implemented.
     */
    public static FriendEntry fromPlayerName (PlayerName playerName, Status status)
    {
        MediaDesc photo = null; // TODO
        String statusMessage = null; // TODO
        return new FriendEntry(new VizPlayerName(playerName, photo), status, statusMessage);
    }

    /** Mr. Constructor. */
    public FriendEntry (VizPlayerName name, Status status, String statusMessage)
    {
        super(name);
        this.status = status;
        this.statusMessage = statusMessage;
    }

    /** Copies this friend entry. */
    public FriendEntry clone ()
    {
        try {
            return (FriendEntry)super.clone();
        } catch (CloneNotSupportedException e) {
            throw new AssertionError(e);
        }
    }
}
