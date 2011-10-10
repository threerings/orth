//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.instance.server;

import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.BodyObject;

import com.threerings.whirled.data.Scene;
import com.threerings.whirled.server.SceneRegistry;
import com.threerings.whirled.spot.data.Location;
import com.threerings.whirled.spot.server.SpotSceneManager;
import com.threerings.whirled.util.UpdateList;

import com.threerings.orth.Log;

public class InstancedSceneManager extends SpotSceneManager
{
    public Instance getInstance ()
    {
        return _instance;
    }

    @Override public void handleChangeLoc (BodyObject source, Location loc)
        throws InvocationException
    {
        super.handleChangeLoc(source, loc);
    }

    public void setSceneData (Scene scene, UpdateList updates, Object extras,
        Instance instance, SceneRegistry screg)
    {
        super.setSceneData(scene, updates, extras, screg);
        _instance = instance;
    }

    @Override protected void setSceneData (
        Scene scene, UpdateList updates, Object extras, SceneRegistry screg)
    {
        throw new RuntimeException("This method must not be called in instanced mode.");
    }

    protected Instance _instance;
}
