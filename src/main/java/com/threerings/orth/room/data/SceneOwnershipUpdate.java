//
// $Id$

package com.threerings.orth.room.data;

import com.threerings.util.Name;
import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.data.SceneUpdate;

public class SceneOwnershipUpdate extends SceneUpdate
{
    /** The new owner type. */
    public byte ownerType;

    /** The new owner id. */
    public int ownerId;

    /** The new owner name. */
    public Name ownerName;

    /** If true, change the access type to ACCESS_OWNER_ONLY */
    public boolean lockToOwner;

    @Override
    public void apply (SceneModel model)
    {
        super.apply(model);

        OrthSceneModel mmodel = (OrthSceneModel) model;
        mmodel.ownerType = ownerType;
        mmodel.ownerId = ownerId;
        mmodel.ownerName = ownerName;
        if (lockToOwner) {
            mmodel.accessControl = OrthSceneModel.ACCESS_OWNER_ONLY;
        }
    }
}
