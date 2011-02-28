//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.util.ByteEnum;

public class EntityType extends ByteEnum
{
    public static const NOT_A_TYPE :EntityType = new EntityType("NOT_A_TYPE", 0);

    public function EntityType (name :String, code :int)
    {
        super(name, code);
    }

    // ORTH TODO: see MSOY's RoomController.ENTITY_TYPES
    public function getPropertyType () :String
    {
        throw new Error("abstract");
    }
}
}
