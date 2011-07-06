//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.notify.data;

import com.threerings.orth.data.PlayerName;

public class GuildInviteNotification extends Notification
{
    public GuildInviteNotification (PlayerName sender, String guildName, int guildId)
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

    protected PlayerName _sender;
    protected String _guildName;
    protected int _guildId;
}
