//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.Tell;

public class ChatLengthMonitor
    implements ChatMonitor
{
    public final int maxLength;

    public ChatLengthMonitor (int maxLength)
    {
        this.maxLength = maxLength;
    }

    @Override
    public boolean check (Tell tell)
    {
        return tell.getMessage().length() <= maxLength;
    }

    @Override
    public boolean check (Speak speak)
    {
        return speak.getMessage().length() <= maxLength;
    }
}
