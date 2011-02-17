package com.threerings.orth.room.data
{
import com.threerings.util.ByteEnum;

public class EntityIdent_EntityType extends ByteEnum
{
    public function EntityIdent_EntityType (name :String, code :int)
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
