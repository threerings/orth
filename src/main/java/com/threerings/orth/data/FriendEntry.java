//
// $Id$

package com.threerings.orth.data;

import com.threerings.orth.aether.data.VizPlayerName;

/**
 * Represents a friend connection.
 */
public class FriendEntry extends PlayerEntry
{
    /** This player's current status. */
    public String status;

    /** Whether this friend is online.
     * TODO: should this be in the superclass? */
    public boolean online;

    /** Mr. Constructor. */
    public FriendEntry (VizPlayerName name, String status, boolean online)
    {
        super(name);
        this.status = status;
        this.online = online;
    }

    @Override
    public String toString ()
    {
        return "FriendEntry[" + name + "]";
    }
}
