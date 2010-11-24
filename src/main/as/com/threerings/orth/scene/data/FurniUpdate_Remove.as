//
// $Id: FurniUpdate_Remove.as 10500 2008-08-07 19:14:38Z mdb $

package com.threerings.orth.scene.data {
import com.threerings.msoy.room.data.*;

/**
 * Represents the removal of furni from the room.
 */
public class FurniUpdate_Remove extends FurniUpdate
{
    // from FurniUpdate
    override protected function doUpdate (model :MsoySceneModel) :void
    {
        model.removeFurni(data);
    }
}
}
