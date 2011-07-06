//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.comms.data {

import com.threerings.orth.data.PlayerName;

public interface ToComm
{
    function get to () :PlayerName;
}
}
