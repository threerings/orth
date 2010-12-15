//
// $Id$

package com.threerings.orth.player.data;

import com.threerings.orth.data.OrthName;

public class PlayerName extends OrthName
{
    /** For unserialization. */
    public PlayerName ()
    {
    }

    /**
     * Creates a new name with the supplied data.
     */
    public PlayerName (String displayName, int playerId)
    {
        super(displayName, playerId);
    }
}
