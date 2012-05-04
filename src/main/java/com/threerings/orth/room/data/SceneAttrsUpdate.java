//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.data.SceneUpdate;

/**
 * Encodes a scene update that updates the attributes in the MsoySceneModel.  Note that this
 * contains all attributes, even ones that have not changed.  In other words, a field being null
 * doesn't mean that the field isn't updated, it means the new value should be null.
 */
public class SceneAttrsUpdate extends SceneUpdate
{
    /** The new name. */
    public String name;

    /** Full description of the new decor. */
    public DecorData decor;

    @Override
    public void apply (SceneModel model)
    {
        super.apply(model);

        OrthSceneModel mmodel = (OrthSceneModel) model;
        mmodel.name = name;
        mmodel.decor = decor;
    }

    @Override
    public void validate (SceneModel model)
        throws IllegalStateException
    {
        super.validate(model);
    }
}
