//
// $Id: FriendEntry.java 16520 2009-05-08 01:47:50Z ray $

package com.threerings.orth.data;

/**
 * Represents a friend connection.
 */
public class FriendEntry extends PlayerEntry
{
    /** This player's current status. */
    public String status;

    /** Suitable for deserialization. */
    public FriendEntry ()
    {
    }

    /** Mr. Constructor. */
    public FriendEntry (VizOrthName name, String status)
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
