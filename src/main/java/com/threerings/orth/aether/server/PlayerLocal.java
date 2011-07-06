//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import java.util.List;
import java.util.Set;

import com.google.common.collect.Lists;

import com.threerings.crowd.server.BodyLocal;
import com.threerings.orth.notify.data.Notification;
import com.threerings.orth.notify.data.NotificationLocal;
import com.threerings.orth.server.util.InviteThrottle;

/**
 * Maintain PlayerObject-related data that should only exist server-side.
 */
public class PlayerLocal extends BodyLocal
    implements NotificationLocal
{
    /** A list of notifications that will be dispatched when the client's NotificationDirector asks
     * for them. Will be null once the deferred notifications have been dispatched. */
    public List<Notification> deferredNotifications;

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
        // create a deferred notifications array so that we can track any notifications dispatched
        // to this client until they're ready to read them; we'd have NotificationManager do this
        // in a PlayerLocator.Observer but we need to be sure this is filled in before any other
        // PlayerLocator.Observers are notified because that's precisely when early notifications
        // are likely to be generated
        deferredNotifications = Lists.newArrayList();
    }

    public InviteThrottle getInviteThrottle ()
    {
        if (friendInviteThrottle == null) {
            friendInviteThrottle = new InviteThrottle();
        }
        return friendInviteThrottle;
    }

    @Override
    public List<Notification> getAndClearDeferredNotifications ()
    {
        List<Notification> notifications = deferredNotifications;
        deferredNotifications = null;
        return notifications;
    }

    @Override
    public boolean stillDeferringNotifications ()
    {
        return deferredNotifications != null;
    }

    @Override
    public void deferNotifications (List<Notification> notifications)
    {
        deferredNotifications.addAll(notifications);
    }
}
