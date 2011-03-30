package com.threerings.orth.aether.server;

import java.util.List;
import java.util.Map;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

import com.threerings.crowd.server.BodyLocal;
import com.threerings.orth.notify.data.Notification;
import com.threerings.orth.notify.data.NotificationLocal;

/**
 * Maintain PlayerObject-related data that should only exist server-side.
 */
public class PlayerLocal extends BodyLocal
    implements NotificationLocal
{
    /** A list of notifications that will be dispatched when the client's NotificationDirector asks
     * for them. Will be null once the deferred notifications have been dispatched. */
    public List<Notification> deferredNotifications;

    /** Ids of players that this player has sent friend requests to, but have not replied, mapped
     * to the timestamp when the request was made. */
    public Map<Integer, Long> pendingFriendRequests;

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
        pendingFriendRequests = Maps.newHashMap();
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
