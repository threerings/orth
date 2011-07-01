//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.data.OrthName;

public class Speak extends SimpleStreamableObject
{
    public Speak (OrthName from, String message)
    {
        _from = from;
        _message = message;
    }

    protected OrthName _from;
    protected String _message;
}
