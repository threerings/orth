package com.threerings.orth.notify.data;

import com.threerings.orth.aether.data.PlayerName;

/**
 * Notification sent when friendship is requested.
 */
public class FriendInviteNotification extends Notification
{
    /** Creates a new notification for deserializing. */
    public FriendInviteNotification()
    {
    }

    /** Creates a new notification for the given sender. */
    public FriendInviteNotification(PlayerName sender)
    {
        _sender = sender;
    }

    @Override
    public String getAnnouncement ()
    {
        // implemented on client
        return null;
    }

    /** The player that wants to be friends. */
    protected PlayerName _sender;
}
