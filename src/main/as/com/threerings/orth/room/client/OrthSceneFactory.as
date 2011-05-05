//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.client {

import com.threerings.crowd.data.PlaceConfig;
import com.threerings.whirled.data.Scene;
import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.util.SceneFactory;

import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.OrthSceneModel;

/**
 * The client-side scene factory in use by the orth client.
 */
public class OrthSceneFactory
    implements SceneFactory
{
    // documentation inherited from interface SceneFactory
    public function createScene (model :SceneModel, config :PlaceConfig) :Scene
    {
        return new OrthScene(model as OrthSceneModel, config);
    }
}
}
