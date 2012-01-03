//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import javax.annotation.Generated;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

import com.threerings.whirled.client.SceneService;

import com.threerings.orth.room.client.OrthSceneService;
import com.threerings.orth.room.data.RoomLocus;

/**
 * Defines the server-side of the {@link OrthSceneService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from OrthSceneService.java.")
public interface OrthSceneProvider extends InvocationProvider
{
    /**
     * Handles a {@link OrthSceneService#moveTo} request.
     */
    void moveTo (ClientObject caller, RoomLocus arg1, int arg2, int arg3, SceneService.SceneMoveListener arg4)
        throws InvocationException;
}
