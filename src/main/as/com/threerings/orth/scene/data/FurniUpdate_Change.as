//
// $Id: FurniUpdate_Change.as 10500 2008-08-07 19:14:38Z mdb $

package com.threerings.orth.scene.data {
import com.threerings.msoy.room.data.*;

/**
 * Represents the change of furni in the room.
 */
public class FurniUpdate_Change extends FurniUpdate
{
    // from FurniUpdate
    override protected function doUpdate (model :MsoySceneModel) :void
    {
        model.removeFurni(data);
        model.addFurni(data);
    }
}
}
