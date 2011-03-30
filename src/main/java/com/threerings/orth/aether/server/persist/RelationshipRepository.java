package com.threerings.orth.aether.server.persist;

import java.util.Collection;

/**
 * Methods for managing persistent relationships between players.
 */
public interface RelationshipRepository
{
    /**
     * Adds a symmetric friend relationship between the two players with the given ids.
     */
    public void addFriendship (int playerId1, int playerId2);

    /**
     * Removes a symmetric friend relationship between the two players with the given ids.
     * @return true if the relation existed and was remove, false if not
     */
    public boolean removeFriendship (int playerId1, int playerId2);

    /**
     * Retrieves all the player ids of the friends of the given player.
     */
    public Collection<Integer> getFriendIds (int playerId);
}
