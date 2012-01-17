//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.aether.data {

import com.threerings.orth.comms.data.OneToOneComm;
import com.threerings.orth.data.PlayerName;

/**
 * A notification comm for player logon/logoff. Exists only AS-side for now, as the event
 * is triggered on the client.
 */
public class FriendLogOnOffComm
    implements OneToOneComm
{
    public function FriendLogOnOffComm (from :PlayerName, to :PlayerName, logon :Boolean)
    {
        _from = from;
        _to = to;
        _logon = logon;
    }

    public function get fromMessage () :String
    {
        return null;
    }

    public function get toMessage () :String
    {
        return "Your friend " + _from + " has logged " + (_logon ? "on" : "off") + ".";
    }

    public function get to () :PlayerName
    {
        return _to;
    }

    public function get from () :PlayerName
    {
        return _from;
    }

    protected var _from :PlayerName;
    protected var _to :PlayerName;
    protected var _logon :Boolean;
}
}
