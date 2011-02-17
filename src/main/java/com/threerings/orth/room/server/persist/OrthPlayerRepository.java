//
// $Id$

package com.threerings.orth.room.persist.server;

public interface OrthPlayerRepository
{
    int loadPlayerIdForSession (String token);
}
