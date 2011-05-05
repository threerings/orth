//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.server.persist;

import java.util.Map;

public interface OrthPlayerRepository
{
    OrthPlayerRecord loadPlayer (int playerId);
    OrthPlayerRecord loadPlayerForSession (String token);

    // TODO: this is currently only used for friend entries. If we end up sending player's photos
    // in VizPlayerName and therefore FriendEntry, this can perhaps just change to FriendEntry
    // values
    Map<Integer, String> resolvePlayerNames (Iterable<Integer> playerIds);
}
