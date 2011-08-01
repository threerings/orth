//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client {

import com.threerings.presents.client.InvocationService;

import com.threerings.whirled.client.SceneService_SceneMoveListener;

import com.threerings.orth.room.data.OrthLocation;

/**
 * An ActionScript version of the Java OrthSceneService interface.
 */
public interface OrthSceneService extends InvocationService
{
    // from Java interface OrthSceneService
    function moveTo (arg1 :int, arg2 :int, arg3 :int, arg4 :OrthLocation, arg5 :SceneService_SceneMoveListener) :void;
}
}
