//
// $Id: FurniUpdate_Add.as 10500 2008-08-07 19:14:38Z mdb $

package com.threerings.orth.room.data {

/**
 * Represents the addition of furniture to a room.
 */
public class FurniUpdate_Add extends FurniUpdate
{
    // from FurniUpdate
    override protected function doUpdate (model :OrthSceneModel) :void
    {
        model.addFurni(data);
    }
}
}
