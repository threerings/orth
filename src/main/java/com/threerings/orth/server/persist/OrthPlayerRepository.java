//
// $Id$

package com.threerings.orth.server.persist;

public interface OrthPlayerRepository
{
    int loadPlayerIdForSession (String token);
}
