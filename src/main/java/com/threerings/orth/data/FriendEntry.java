//
// $Id$

package com.threerings.orth.data;

import com.samskivert.util.StringUtil;

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

    /** Whether this friend is online.
     * TODO: should this be in the superclass? */
    public Status status;

    /** This player's current status. */
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

    @Override
    public String toString ()
    {
        StringBuilder sb = new StringBuilder("FriendEntry [");
        StringUtil.fieldsToString(sb, this);
        return sb.append("]").toString();
    }
}
