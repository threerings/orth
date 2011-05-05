//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.notify.data;

import java.util.List;

/**
 * Extra requirements on a ClientLocal subclass to be able to export deferred notifications
 * that accumulate server+side until the player is able to receive them.
 */
public interface NotificationLocal
{
    /** Returns queued-up notifications than switches to broadcast mode. */
    List<Notification> getAndClearDeferredNotifications ();

    /** Tells us if we're still in the notification deferring phase. */
    boolean stillDeferringNotifications ();

    /** Queue up the given notifications. */
    void deferNotifications (List<Notification> notifications);
}
