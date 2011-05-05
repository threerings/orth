//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.client {

import com.threerings.orth.room.data.OrthLocation;

/**
 * Returned by RoomView's pointToLocation().
 * Encodes a world location, as well as information about where the click
 * actually landed so that entities can make informed decisions about
 * what to do with the location.
 */
public class ClickLocation
{
    public static const FLOOR :int = 0;
    public static const CEILING :int = 1;
    public static const LEFT_WALL :int = 2;
    public static const RIGHT_WALL :int = 3;
    public static const FRONT_WALL :int = 4;
    public static const BACK_WALL :int = 5;

    protected static const WALL_DEBUG_NAMES :Array =
        [ "floor", "ceiling", "left wall", "right wall", "front wall", "back wall" ];

    /** Where the click actually landed. */
    public var click :int;

    /** The world coordinate of the click. */
    public var loc :OrthLocation;

    /**
     * Construct a ClickLocation.
     */
    public function ClickLocation (click :int, loc :OrthLocation)
    {
        this.click = click;
        this.loc = loc;
    }

    /** Prints click location in human-readable form. */
    public function toString () :String
    {
        return "[ClickLocation: click=" + WALL_DEBUG_NAMES[click] + ", loc=" + loc + "]";
    }
}
}
