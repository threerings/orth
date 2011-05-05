//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.chat.data;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.orth.aether.data.PlayerName;

public class Tell extends SimpleStreamableObject
{
    public Tell ()
    {
    }

    public Tell (PlayerName from, String message)
    {
        _from = from;
        _message = message;
    }

    protected PlayerName _from;
    protected String _message;
}
