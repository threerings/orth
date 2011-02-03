//
// $Id: FollowInviteNotification.java 19625 2010-11-24 15:47:54Z zell $

package com.threerings.orth.notify.data;

import com.threerings.util.ActionScript;
import com.threerings.util.MessageBundle;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.notify.data.Notification;

/**
 * Notifies a user that they have been requested to play a game
 */
public class FollowInviteNotification extends Notification
{
    public FollowInviteNotification ()
    {
    }

    @ActionScript(omit=true)
    public FollowInviteNotification (PlayerName inviter)
    {
        _inviter = inviter.toPlayerName();
    }

    // from Notification
    public String getAnnouncement ()
    {
        return MessageBundle.tcompose("m.follow_invite", _inviter, _inviter.getId());
    }

    @Override
    public PlayerName getSender ()
    {
        return _inviter;
    }

    protected PlayerName _inviter;
}
