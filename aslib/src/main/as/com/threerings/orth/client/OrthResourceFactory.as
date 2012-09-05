//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.client {

import flash.display.DisplayObject;

public interface OrthResourceFactory
{
    function newIdleIcon () :DisplayObject;
    function newWalkTarget () :DisplayObject;
    function newFlyTarget () :DisplayObject;
}
}
