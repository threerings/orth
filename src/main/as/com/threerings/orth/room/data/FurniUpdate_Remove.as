//
// $Id: FurniUpdate_Remove.as 10500 2008-08-07 19:14:38Z mdb $

package com.threerings.orth.room.data {

/**
 * Represents the removal of furni from the room.
 */
public class FurniUpdate_Remove extends FurniUpdate
{
    // from FurniUpdate
    override protected function doUpdate (model :OrthSceneModel) :void
    {
        model.removeFurni(data);
    }
}
}
