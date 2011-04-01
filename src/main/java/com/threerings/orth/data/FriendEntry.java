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

     /** Mr. Constructor. */
    public FriendEntry (VizPlayerName name, String status)
    {
    	super(name);
        this.status = status;
    }

    @Override
    public String toString ()
    {
        return "FriendEntry[" + name + "]";
    }
}
