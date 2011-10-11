//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.instance.server;

import com.threerings.whirled.data.Scene;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.server.SceneRegistry;
import com.threerings.whirled.spot.server.SpotSceneManager;
import com.threerings.whirled.util.UpdateList;

import com.threerings.orth.instance.data.Instance;

public class InstancedSceneManager extends SpotSceneManager
{
    /**
     * Return the instance of this scene we're managing, or null.
     */
    public Instance getInstance ()
    {
        return _instance;
    }

    /**
     * When we're representing an instanced scene, it's this method that's called, rather
     * than {@link SceneManager#setSceneData(Scene, UpdateList, Object, SceneRegistry)}.
     */
    public void setSceneData (Scene scene, UpdateList updates, Object extras,
        Instance instance, SceneRegistry screg)
    {
        super.setSceneData(scene, updates, extras, screg);
        _instance = instance;
    }

    protected Instance _instance;
}
