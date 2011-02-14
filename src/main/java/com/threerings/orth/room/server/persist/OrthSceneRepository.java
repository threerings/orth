//
// $Id$

package com.threerings.orth.room.server.persist;

import java.io.IOException;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.orth.entity.data.Decor;
import com.threerings.orth.room.data.OrthSceneModel;
import com.threerings.whirled.server.persist.SceneRepository;
import com.threerings.whirled.util.NoSuchSceneException;
import com.threerings.whirled.data.SceneModel;

@Singleton
public class OrthSceneRepository
    implements SceneRepository
{
    public SceneModel loadSceneModel (int sceneId)
        throws IOException, NoSuchSceneException
    {
        if (sceneId != 1) {
            throw new IllegalArgumentException("Only scene 1 has been implemented!");
        }
        return OrthSceneModel.blankOrthSceneModel();
    }

    public void storeSceneModel (SceneModel model)
        throws IOException
    {
        throw new IllegalStateException("not implemented");
    }

    public void deleteSceneModel (int sceneId)
        throws IOException
    {
        throw new IllegalStateException("not implemented");
    }
}
