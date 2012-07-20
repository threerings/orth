//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import java.util.Set;

import com.threerings.crowd.server.BodyLocal;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.server.util.InviteThrottle;

/**
 * Maintain PlayerObject-related data that should only exist server-side.
 */
public class AetherLocal extends BodyLocal
{
    /** Throttle for friend requests sent by this player. */
    public InviteThrottle friendInviteThrottle;

    /**
     * The set of playerIds for our friends, initialized during client resolution and later
     * cleared from {@link FriendManager#initFriends(AetherClientObject)}.
     */
    public Set<Integer> unresolvedFriendIds;

    /**
     * Called during client resolution to prepare this local data for use.
     */
    public void init ()
    {
    }

    public InviteThrottle getInviteThrottle ()
    {
        if (friendInviteThrottle == null) {
            friendInviteThrottle = new InviteThrottle();
        }
        return friendInviteThrottle;
    }
}
