//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.data.SceneUpdate;

/**
 * The base for all furni updates.
 */
public abstract class FurniUpdate extends SceneUpdate
{
    /** Indicates that furniture has been added to a scene. */
    public static class Add extends FurniUpdate
    {
        @Override
        protected void doUpdate (OrthSceneModel model) {
            model.addFurni(data);
        }
    }

    /** Indicates that furniture has been removed from a scene. */
    public static class Remove extends FurniUpdate
    {
        @Override
        protected void doUpdate (OrthSceneModel model) {
            model.removeFurni(data);
        }
    }

    /** Indicates that furniture in a scene has been changed. */
    public static class Change extends FurniUpdate
    {
        @Override
        protected void doUpdate (OrthSceneModel model) {
            model.updateFurni(data);
        }
    }

    /** The furni being operated on by this update. */
    public FurniData data;

    @Override // from SceneUpdate
    public void apply (SceneModel model)
    {
        super.apply(model);
        doUpdate((OrthSceneModel)model);
    }

    @Override // from SceneUpdate
    protected void toString (StringBuilder buf)
    {
        String cname = getClass().getName();
        buf.append(cname.substring(cname.lastIndexOf("$")+1)).append(", ");
        super.toString(buf);
    }

    protected abstract void doUpdate (OrthSceneModel model);
}
