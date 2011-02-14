//
// $Id$

package com.threerings.orth.room.server.persist;

import java.io.IOException;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.whirled.client.persist.SceneRepository;
import com.threerings.whirled.util.NoSuchSceneException;
import com.threerings.whirled.data.SceneModel;

@Singleton
public class OrthSceneRepository
    implements SceneRepository
{
    public SceneModel loadSceneModel (int sceneId)
        throws IOException, NoSuchSceneException
    {
        // ORTH TODO
        return null;        
    }

    public void storeSceneModel (SceneModel model)
        throws IOException
    {
        // ORTH TODO
        throw new IllegalStateException("not implemented");
    }

    public void deleteSceneModel (int sceneId)
        throws IOException
    {
        // ORTH TODO
        throw new IllegalStateException("not implemented");
    }
}