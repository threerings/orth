//
// $Id$

package com.threerings.orth.server.persist;

public interface OrthPlayerRepository
{
    OrthPlayerRecord loadPlayer (int playerId);
    OrthPlayerRecord loadPlayerForSession (String token);
}
