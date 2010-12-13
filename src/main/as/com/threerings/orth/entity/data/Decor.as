//
// $Id: $

package com.threerings.orth.entity.data {

/**
 * Client-side information about the kind of entity that can be the backdrop canvas for a room.
 */
public interface Decor
    extends Entity
{
    function setType (type :int) :void;

    function getHorizon () :Number;

    function getDepth () :int;

    function getWidth () :int;

    function getHeight () :int;

    function getActorScale () :Number;

    function getFurniScale () :Number;

    function getDecorType () :int;

    function doHideWalls () :Boolean;

}
}
