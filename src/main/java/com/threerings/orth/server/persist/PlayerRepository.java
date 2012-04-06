//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.server.persist;

import java.util.Map;

public interface PlayerRepository
{
    PlayerRecord loadPlayer (int playerId);
    PlayerRecord loadPlayerForSession (String token);

    String resolvePlayerName (int playerId);
    Map<Integer, String> resolvePlayerNames (Iterable<Integer> playerIds);
}
