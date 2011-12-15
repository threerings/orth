//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.orth.comms.data.BaseOneToOneComm;

public class Broadcast extends BaseOneToOneComm
{
    // TODO: This should perhaps just implement a pure 'Comm'
    public Broadcast (String message)
    {
        super(null, null);
        _message = message;
    }

    public String getMessage ()
    {
        return _message;
    }

    protected String _message;
}
