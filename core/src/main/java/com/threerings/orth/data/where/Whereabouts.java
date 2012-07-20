//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data.where;

import com.threerings.io.SimpleStreamableObject;

public abstract class Whereabouts extends SimpleStreamableObject
{
    /** Indicate that all that's known is that the player is offline. */
    public static final Offline OFFLINE = new Offline();

    /** Indicate that all that's known is that the player is online. */
    public static final Online ONLINE = new Online();

    /**
     * Returns a translatable description of the player's whereabouts.
     */
    public abstract String getDescription ();

    /**
     * Checks whether the player is online.
     */
    public abstract boolean isOnline ();
}
