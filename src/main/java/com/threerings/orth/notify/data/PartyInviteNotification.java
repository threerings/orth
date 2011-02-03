//
// $Id$

package com.threerings.orth.notify.data;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.notify.data.Notification;

public class PartyInviteNotification extends Notification
{
    /** Suitable for unserialization. */
    public PartyInviteNotification () {}

    /** Normal constructor. */
    public PartyInviteNotification (PlayerName inviter, int partyId, String partyName)
    {
        _inviter = inviter.toPlayerName();
        _partyId = partyId;
        _partyName = partyName;
    }

    @Override
    public String getAnnouncement ()
    {
        return null; // implemented on the client
    }

    @Override
    public PlayerName getSender ()
    {
        return _inviter;
    }

    protected PlayerName _inviter;
    protected int _partyId;
    protected String _partyName;
}
