//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.data.PlayerName;

public class Tell extends BaseOneToOneComm
{
    public Tell (PlayerName from, PlayerName to, String message)
    {
        super(from, to);
    }

    protected String _message;
}
