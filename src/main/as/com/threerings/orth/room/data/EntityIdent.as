//
// $Id: ActorInfo.java 16914 2009-05-27 05:54:19Z mdb $

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
