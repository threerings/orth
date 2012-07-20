//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.data.PlayerName;

/**
 * Note: At this point, Speak is so close to Narya's ChatMessage that it really doesn't have
 * much reason for continued existence, especially since we actually convert to UserMessage
 * instances on the client. This class, along with Tell, should likely be deleted ASAP.
 */
public class Speak extends SimpleStreamableObject
{
    public Speak (PlayerName from, String message, String localType)
    {
        _from = from;
        _message = message;
        _localType = localType;
    }

    public String getMessage ()
    {
        return _message;
    }

    public String getLocalType ()
    {
        return _localType;
    }

    public PlayerName getFrom ()
    {
        return _from;
    }

    protected PlayerName _from;
    protected String _message;
    protected String _localType;
}
