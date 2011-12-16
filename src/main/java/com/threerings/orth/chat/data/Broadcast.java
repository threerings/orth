//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.orth.data.ModuleStreamable;

public class Broadcast extends ModuleStreamable
{
    public Broadcast (String message)
    {
        _message = message;
    }

    public String getMessage ()
    {
        return _message;
    }

    protected String _message;
}
