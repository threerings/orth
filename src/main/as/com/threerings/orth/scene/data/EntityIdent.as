//
// $Id: ActorInfo.java 16914 2009-05-27 05:54:19Z mdb $

package com.threerings.orth.scene.data {

import com.threerings.io.Streamable;

import com.threerings.util.Comparable;
import com.threerings.util.Hashable;

public interface EntityIdent extends Streamable, Hashable, Comparable
{
    function getType () :int;
    function getItem () :int;
}
}
