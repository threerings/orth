//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.client {

import flash.display.DisplayObject;

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

    // editor resources

    /** The sprite image used for positioning the entrance location. */
    function get edEntrance () :Class;
    function get edHotspotMoveXZ () :Class;
    function get edHotspotMoveY () :Class;
    function get edButtonAccessEveryone () :Class;
    function get edButtonAccessOwnerAndFriends () :Class;
    function get edButtonAccessOwnerOnly () :Class;
    function get edHotspotScale () :Class;
    function get edHotspotScaleOverLeft () :Class;
    function get edHotspotScaleOverRight () :Class;
    function get edHotspotRotating () :Class;
}
}
