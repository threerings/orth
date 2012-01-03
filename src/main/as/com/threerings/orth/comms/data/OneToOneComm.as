//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.comms.data {

public interface OneToOneComm extends ToComm, FromComm
{
    /** Returns a message appropriate to display to the to participant in this comm */
    function get toMessage () :String;

    /** Returns a message appropriate to display to the from participant in this comm */
    function get fromMessage () :String;
}
}
