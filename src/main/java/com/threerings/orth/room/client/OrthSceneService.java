//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;

import com.threerings.whirled.client.SceneService.SceneMoveListener;
import com.threerings.whirled.client.SceneService;

import com.threerings.orth.room.data.OrthLocation;

/**
 * Extends the {@link SceneService} with a scene traversal mechanism needed by Orth.
 */
public interface OrthSceneService extends InvocationService<ClientObject>
{
    /**
     * Requests that that this client's body be moved to the specified scene.
     *
     * @param sceneId the scene id to which we want to move.
     * @param version the version number of the scene object that we have in our local repository.
     * @param portalId the id of the portal via which we are departing the current scene, or 0.
     * @param destLoc the location in the target scene where the client wishes to enter.
     */
    public void moveTo (int sceneId, int version, int portalId,
        OrthLocation destLoc, SceneMoveListener listener);
}
