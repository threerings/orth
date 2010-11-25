//
// $Id: OrthSceneModel.as 18842 2009-12-11 20:38:56Z zell $

package com.threerings.orth.room.data {

public interface DecorGeometry
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
