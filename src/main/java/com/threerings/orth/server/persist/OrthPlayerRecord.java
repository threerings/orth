//
// $Id: $


package com.threerings.orth.server.persist;

/**
 * Just enough information about a player for Orth to do what it needs to do.
 */
public interface OrthPlayerRecord
{
    public int getPlayerId ();
    public String getPlayerName ();
}
