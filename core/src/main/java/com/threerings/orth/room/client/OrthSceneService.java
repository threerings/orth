//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.client;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;

import com.threerings.whirled.client.SceneService.SceneMoveListener;
import com.threerings.whirled.client.SceneService;

import com.threerings.orth.room.data.RoomLocus;

/**
 * Extends the {@link SceneService} with a scene traversal mechanism needed by Orth.
 */
public interface OrthSceneService extends InvocationService<ClientObject>
{
    /**
     * Requests that that this client's body be moved to the specified scene.
     *
     * @param locus the {@link RoomLocus} where we want to go
     * @param version the version number of the scene object that we have in our local repository.
     * @param portalId the id of the portal via which we are departing the current scene, or 0.
     */
    public void moveTo (RoomLocus locus, int version, int portalId, SceneMoveListener listener);
}
