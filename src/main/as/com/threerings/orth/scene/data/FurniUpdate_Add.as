//
// $Id: FurniUpdate_Add.as 10500 2008-08-07 19:14:38Z mdb $

package com.threerings.orth.scene.data {
import com.threerings.msoy.room.data.*;

/**
 * Represents the addition of furniture to a room.
 */
public class FurniUpdate_Add extends FurniUpdate
{
    // from FurniUpdate
    override protected function doUpdate (model :MsoySceneModel) :void
    {
        model.addFurni(data);
    }
}
}
