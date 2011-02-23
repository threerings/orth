//
// $Id$

package com.threerings.orth.notify.data;

import com.threerings.orth.data.OrthName;
import com.threerings.orth.notify.data.Notification;

public class PartyInviteNotification extends Notification
{
    /** Suitable for unserialization. */
    public PartyInviteNotification () {}

    /** Normal constructor. */
    public PartyInviteNotification (OrthName inviter, int partyId, String partyName)
    {
        _inviter = inviter;
        _partyId = partyId;
        _partyName = partyName;
    }

    @Override
    public String getAnnouncement ()
    {
        return null; // implemented on the client
    }

    @Override
    public OrthName getSender ()
    {
        return _inviter;
    }

    protected OrthName _inviter;
    protected int _partyId;
    protected String _partyName;
}
