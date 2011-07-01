//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.notify.data;

import com.threerings.orth.data.OrthName;

public class GuildInviteNotification extends Notification
{
    public GuildInviteNotification (OrthName sender, String guildName, int guildId)
    {
        _sender = sender;
        _guildName = guildName;
        _guildId = guildId;
    }

    @Override
    public String getAnnouncement ()
    {
        return null; // ?
    }

    protected OrthName _sender;
    protected String _guildName;
    protected int _guildId;
}
