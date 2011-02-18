//
// $Id$

package com.threerings.orth.server.persist;

public interface OrthPlayerRepository
{
    OrthPlayerRecord  loadPlayerForSession (String token);
}
