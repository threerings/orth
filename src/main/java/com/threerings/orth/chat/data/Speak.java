//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.data.PlayerName;

public class Speak extends SimpleStreamableObject
{
    public Speak (PlayerName from, String message)
    {
        _from = from;
        _message = message;
    }

    public String getMessage ()
    {
        return _message;
    }

    public PlayerName getFrom ()
    {
        return _from;
    }

    protected PlayerName _from;
    protected String _message;
}
