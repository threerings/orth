//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.data {

import com.threerings.io.Streamable;

import com.threerings.util.Comparable;
import com.threerings.util.Hashable;

public interface EntityIdent extends Streamable, Hashable, Comparable
{
    function getType () :EntityType;
    function getItem () :int;

    /** Create a dependable string representation of this Ident, on the format typeNum:itemNum */
    function toString () :String;
}
}
