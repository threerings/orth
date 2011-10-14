//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data {
import com.threerings.orth.ui.ObjectMediaDesc;

/**
 * Client-side information about the kind of entity that can be the backdrop canvas for a room.
 */
public interface Decor
{
    function getHorizon () :Number;

    function getDepth () :int;

    function getWidth () :int;

    function getHeight () :int;

    function getActorScale () :Number;

    function getFurniScale () :Number;

    function getDecorType () :int;

    function getWalkability () :ObjectMediaDesc;

    function doHideWalls () :Boolean;
}
}
