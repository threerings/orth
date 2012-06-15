//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.aether.data {

import com.threerings.orth.comms.data.ToOneComm;
import com.threerings.orth.data.PlayerName;

/**
 * A notification comm for player logon/logoff. Exists only AS-side for now, as the event
 * is triggered on the client.
 */
public class PartyMemberNotificationComm
    implements ToOneComm
{
    public static const NOTE_JOIN :int = 3;
    public static const NOTE_LEAVE :int = 4;

    public function PartyMemberNotificationComm (from :PlayerName, to :PlayerName, note :int)
    {
        _from = from;
        _to = to;
        _note = note;
    }

    public function get toMessage () :String
    {
        const head :String = _from + " has ";
        switch (_note) {
        case NOTE_JOIN:
            return head + "joined the party.";
        case NOTE_LEAVE:
            return head + "left the party.";
        default:
            return "???";
        }
    }

    public function get to () :PlayerName
    {
        return _to;
    }

    protected var _from :PlayerName;
    protected var _to :PlayerName;
    protected var _note :int;
}
}
