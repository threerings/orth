//
// $Id$

package com.threerings.orth.persist.server;

public interface OrthPlayerRepository
{
    int loadPlayerIdForSession (String token);
}
