//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import java.util.Set;

import com.threerings.crowd.server.BodyLocal;

import com.threerings.orth.server.util.InviteThrottle;

/**
 * Maintain PlayerObject-related data that should only exist server-side.
 */
public class AetherLocal extends BodyLocal
{
    /** Throttle for friend requests sent by this player. */
    public InviteThrottle friendInviteThrottle;

    /**
     * This is set during client resolution and cleared later after {@link AetherClientObject#friends} is
     * populated.
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
