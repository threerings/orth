//
// $Id$

package com.threerings.orth.client {

import flash.display.DisplayObject;

import mx.core.IFlexDisplayObject;

public interface OrthResourceFactory
{
    function newIdleIcon () :DisplayObject;

    function newWalkTarget () :DisplayObject;
    function newFlyTarget () :DisplayObject;

    function get roomEditIcon () :Class;
    function get snapshotIcon () :Class;
    function get whisperIcon () :Class;
    function get addFriendIcon () :Class;
    function get visitIcon () :Class;
    function get blockIcon () :Class;
    function get reportIcon () :Class;
}
}