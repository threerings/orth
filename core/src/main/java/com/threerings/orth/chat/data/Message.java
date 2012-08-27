//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.orth.comms.data.ToOneComm;
import com.threerings.orth.data.ModuleStreamable;
import com.threerings.orth.data.PlayerName;

public class Message extends ModuleStreamable
    implements ToOneComm
{
    public Message (PlayerName to, String message)
    {
        _to = to;
        _message = message;
    }

    @Override public PlayerName getTo ()
    {
        return _to;
    }

    public String getMessage ()
    {
        return _message;
    }

    protected PlayerName _to;
    protected String _message;
}
