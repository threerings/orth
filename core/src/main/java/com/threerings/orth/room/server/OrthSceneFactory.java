//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import com.google.inject.Singleton;

import com.threerings.crowd.data.PlaceConfig;

import com.threerings.whirled.data.Scene;
import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.server.SceneRegistry;
import com.threerings.whirled.util.SceneFactory;

import com.threerings.orth.room.data.OrthRoomConfig;
import com.threerings.orth.room.data.OrthScene;

/**
 * Scene and config factory for Orth.
 */
@Singleton
public class OrthSceneFactory
    implements SceneFactory, SceneRegistry.ConfigFactory
{
    // from interface SceneFactory
    public Scene createScene (SceneModel model, PlaceConfig config)
    {
        return new OrthScene(model, config);
    }

    // from interface SceneRegistry.ConfigFactory
    public PlaceConfig createPlaceConfig (SceneModel smodel)
    {
        return new OrthRoomConfig();
    }
}
