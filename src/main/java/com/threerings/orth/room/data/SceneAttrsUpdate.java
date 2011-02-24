//
// $Id: SceneAttrsUpdate.java 18590 2009-11-05 10:09:48Z jamie $

package com.threerings.orth.room.data;

import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.data.SceneUpdate;

import com.threerings.orth.entity.data.DecorData;

/**
 * Encodes a scene update that updates the attributes in the MsoySceneModel.  Note that this
 * contains all attributes, even ones that have not changed.  In other words, a field being null
 * doesn't mean that the field isn't updated, it means the new value should be null.
 */
public class SceneAttrsUpdate extends SceneUpdate
{
    /** The new name. */
    public String name;

    /** New access control info. */
    public byte accessControl;

    /** Full description of the new decor. */
    public DecorData decor;

    /** The new entrance location. */
    public OrthLocation entrance;

    @Override
    public void apply (SceneModel model)
    {
        super.apply(model);

        OrthSceneModel mmodel = (OrthSceneModel) model;
        mmodel.name = name;
        mmodel.accessControl = accessControl;
        mmodel.decor = decor;
        mmodel.entrance = entrance;
    }

    @Override
    public void validate (SceneModel model)
        throws IllegalStateException
    {
        super.validate(model);
    }
}
