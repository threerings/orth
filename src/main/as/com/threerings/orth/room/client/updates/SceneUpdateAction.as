//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client.updates {
import com.threerings.util.Log;

import com.threerings.whirled.data.SceneUpdate;

import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.SceneAttrsUpdate;

/**
 * Generates a command to update scene attributes.
 */
public class SceneUpdateAction
    implements UpdateAction
{
    /** Create a new furni update command. */
    public function SceneUpdateAction (oldScene :OrthScene, newScene :OrthScene)
    {
        _oldSceneData = new Object();
        _newSceneData = new Object();

        copySceneAttributes(oldScene.getSceneModel(), _oldSceneData);
        copySceneAttributes(newScene.getSceneModel(), _newSceneData);
    }

    // documentation inherited
    public function makeApply () :SceneUpdate
    {
        return makeUpdate(_newSceneData);
    }

    // documentation inherited
    public function makeUndo () :SceneUpdate
    {
        return makeUpdate(_oldSceneData);
    }

    /** Makes a shallow copy of the salient scene attributes from one object to another. */
    protected function copySceneAttributes (from :Object, to :Object) :void
    {
        for each (var attribute :String in ATTRS_TO_COPY) {
            // sanity check, since we're circumventing model definitions
            if (from.hasOwnProperty(attribute)) {
                to[attribute] = from[attribute];
            } else {
                Log.getLog(this).warning("UpdateAction: trying to copy absent attribute",
                                         "attribute", attribute);
            }
        }
    }

    /** Creates a SceneUpdate to send to the server. */
    protected function makeUpdate (sceneData :Object) :SceneUpdate
    {
        var attrUpdate :SceneAttrsUpdate = new SceneAttrsUpdate();
        copySceneAttributes(sceneData, attrUpdate);
        return attrUpdate;
    }

    /** Names of scene attributes that will be updated during an update. */
    protected static const ATTRS_TO_COPY :Array =
        [ "name", "accessControl", "playlistControl", "decor", "entrance" ];

    protected var _oldSceneData :Object;
    protected var _newSceneData :Object;
}
}
