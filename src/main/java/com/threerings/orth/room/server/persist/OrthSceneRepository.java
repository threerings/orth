//
// $Id$

package com.threerings.orth.room.server.persist;

import java.io.IOException;

import com.google.inject.Inject;
import com.google.inject.Singleton;
import com.samskivert.io.PersistenceException;

import com.threerings.orth.entity.data.Decor;
import com.threerings.orth.room.data.OrthSceneModel;
import com.threerings.whirled.server.persist.SceneRepository;
import com.threerings.whirled.util.NoSuchSceneException;
import com.threerings.whirled.util.UpdateList;
import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.data.SceneUpdate;

@Singleton
public class OrthSceneRepository
    implements SceneRepository
{
    public SceneModel loadSceneModel (int sceneId)
        throws PersistenceException, NoSuchSceneException
    {
        if (sceneId != 1) {
            throw new IllegalArgumentException("Only scene 1 has been implemented!");
        }
        return OrthSceneModel.blankOrthSceneModel();
    }

    public UpdateList loadUpdates (int sceneId)
        throws PersistenceException
    {
        return new UpdateList();
    }

    public Object loadExtras (int sceneId, SceneModel model)
        throws PersistenceException
    {
        return null;
    }

    public void applyAndRecordUpdate (SceneModel model, SceneUpdate update)
        throws PersistenceException
    {
        throw new IllegalStateException("not implemented");
    }
}
