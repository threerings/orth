//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.data;

import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.comms.data.RequestComm;
import com.threerings.orth.data.PlayerName;

/**
 * NOTE: This class has not been tested since it was moved from using the old notification
 * system to the new comms system. By implementing RequestComm, it should be able to hook into
 * the automatic request handling in the Buzz chat system (see Subtitler). More suggestive detail
 * may be found in the AS version of this class.
 */
public class GuildInviteNotification extends BaseOneToOneComm
    implements RequestComm
{
    public GuildInviteNotification (PlayerName from, PlayerName to, String guildName, int guildId)
    {
        super(from, to);
        _guildName = guildName;
        _guildId = guildId;
    }

    protected String _guildName;
    protected int _guildId;
}
