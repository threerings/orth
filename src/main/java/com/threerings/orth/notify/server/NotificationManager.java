//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.notify.server;

import java.util.List;

import com.google.common.collect.ImmutableList;

import com.threerings.presents.dobj.DObject;

import com.threerings.orth.notify.data.Notification;
import com.threerings.orth.notify.data.NotificationLocal;

/**
 * Manager for the notification system, whereby general notifications are sent by the server
 * to a client, most commonly a player body of some kind or other. Notifications
 * pile up on the server in the initial phases until the player is logged on and ready
 * to receive them, at which point we never queue them again, but merely broadcast.
 */
public abstract class NotificationManager
{
    protected NotificationManager (String messageName)
    {
        _messageName = messageName;
    }

    /**
     * Sends a notification to the specified member.
     */
    public void notify (DObject target, Notification note)
    {
        // if they have not yet reported in with a call to dispatchGetDeferredNotifications() then we
        // need to queue this notification up rather than dispatch it directly
        NotificationLocal local = getLocal(target);
        if (local.stillDeferringNotifications()) {
            local.deferNotifications(ImmutableList.of(note));
        } else {
            target.postMessage(_messageName, note);
        }
    }

    /**
     * Dispatches a batch of notifications all at once.
     */
    public void notify (DObject target, List<Notification> notes)
    {
        NotificationLocal local = getLocal(target);
        if (local.stillDeferringNotifications()) {
            local.deferNotifications(notes);
        } else {
            target.startTransaction();
            try {
                for (Notification note : notes) {
                    target.postMessage(_messageName, note);
                }
            } finally {
                target.commitTransaction();
            }
        }
    }

    /**
     * Dispatches any deferred notifications for the specified target and marks them as ready to
     * receive notifications in real time.
     */
    public void dispatchDeferredNotifications (DObject target)
    {
        final NotificationLocal local = getLocal(target);
        if (local.stillDeferringNotifications()) {
            List<Notification> notes = local.getAndClearDeferredNotifications();
            notify(target, notes);
        }
    }

    protected abstract NotificationLocal getLocal (DObject target);

    /** The name of the notification message, i.e. *Object.NOTIFICATION. */
    protected final String _messageName;
}
