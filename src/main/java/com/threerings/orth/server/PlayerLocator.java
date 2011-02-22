//
// $Id$

package com.threerings.orth.server;

/**
 * A class for finding and returning the {@link PlayerObject} associated with
 * the {@link ClientObject} someone logs in with. The default implementation is
 * to assume these are one and then same, but it's entirely possible for an
 * implementing layer to have a small login object which then loads the full
 * {@link PlayerObject} subsequently. All code inside Orth which needs to map
 * the source of an incoming request to a player body uses this class.
 */
public class PlayerLocator
{
    /**
     * Returns the {@link PlayerObject} associated with the given {@link ClientObject}.
     */
    public PlayerObject locatePlayer (ClientObject client)
    {
        return (PlayerObject) client;
    }
}
