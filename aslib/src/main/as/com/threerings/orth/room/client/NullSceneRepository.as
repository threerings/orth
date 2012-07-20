//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.client {

import com.threerings.whirled.client.persist.SceneRepository;
import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.util.NoSuchSceneError;

/**
 * A trivial SceneRepository that remembers no scenes at all on the client.
 */
public class NullSceneRepository
    implements SceneRepository
{
    // from SceneRepository
    public function loadSceneModel (sceneId :int) :SceneModel
    {
        throw new NoSuchSceneError(sceneId);
    }

    public function storeSceneModel (model :SceneModel) :void
    {
        // nada
    }

    public function deleteSceneModel (sceneId :int) :void
    {
        // nada
    }
}
}
