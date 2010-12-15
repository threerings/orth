//
// $Id$

package com.threerings.orth.player.data;

import com.threerings.orth.data.MediaDesc;

public class VizPlayerName extends PlayerName
{
    /** For unserialization. */
    public VizPlayerName ()
    {
    }

    /**
     * Creates a new name with the supplied data.
     */
    public VizPlayerName (String displayName, int playerId, MediaDesc photo)
    {
        super(displayName, playerId);
        _photo = photo;
    }

    public VizPlayerName (PlayerName name, MediaDesc photo)
    {
        super(name.toString(), name.getId());
        _photo = photo;
    }

    /**
     * Returns this player's photo.
     */
    public MediaDesc getPhoto ()
    {
        return _photo;
    }

    /** This player's profile photo. */
    protected MediaDesc _photo;
}
