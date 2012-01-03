//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server.persist;

import java.util.Collection;

/**
 * Methods for managing persistent relationships between players.
 */
public interface RelationshipRepository
{
    /**
     * Adds a symmetric friend relationship between the two players with the given ids. If the
     * friendship is already in place, does nothing.
     */
    public void addFriendship (int playerId1, int playerId2);

    /**
     * Removes a symmetric friend relationship between the two players with the given ids.
     * @return true if the relation existed and was remove, false if not
     */
    public boolean removeFriendship (int playerId1, int playerId2);

    /**
     * Retrieves all the player ids of the friends of the given player. Note that no uniqueness
     * guarantee is made. Some ids may appear twice.
     */
    public Collection<Integer> getFriendIds (int playerId);
}
