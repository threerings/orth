//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.server.util;

import java.util.Map;

import com.google.common.collect.Maps;

import com.threerings.io.Streamable;

/**
 * Tracks the times that invites were sent to other players and allows them to be limited to
 * a maximum frequency.
 */
public class InviteThrottle
    implements Streamable
{
    /**
     * Checks if the target id is currently allowed to receive an invitation. If the target is
     * allowed, then the current time is recorded so that the method will not return true again
     * within the time limit.
     */
    public boolean allow (int targetId)
    {
        Long lastRequest = _sent.get(targetId);
        long now = System.currentTimeMillis();
        if (lastRequest != null && now - lastRequest < MIN_PERIOD) {
            return false;
        }
        _sent.put(targetId, now);
        return true;
    }

    /**
     * Clears the throttle for the given target id. Returns true if allow was previously called
     * with the id.
     */
    public boolean clear (int targetId)
    {
        return _sent.remove(targetId) != null;
    }

    /** Ids of players that have been invited, mapped to the timestamp when the invite was sent. */
    protected Map<Integer, Long> _sent = Maps.newHashMap();

    protected static final long MIN_PERIOD = 60 * 1000L;
}
