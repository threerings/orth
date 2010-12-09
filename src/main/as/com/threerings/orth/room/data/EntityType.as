package com.threerings.orth.room.data
{
import com.threerings.util.ByteEnum;

public class EntityType extends ByteEnum
{
    public function EntityType (name :String, code :int, propType :String)
    {
        super(name, code);

        _propType = propType;
    }

    public function getPropertyType () :String
    {
//     ENTITY_TYPES[ItemTypes.FURNITURE] = "furni";
//     ENTITY_TYPES[ItemTypes.TOY] = "furni";
//     ENTITY_TYPES[ItemTypes.DECOR] = "furni";
//     ENTITY_TYPES[ItemTypes.AVATAR] = "avatar";
//     ENTITY_TYPES[ItemTypes.OCCUPANT] = "avatar";
//     ENTITY_TYPES[ItemTypes.PET] = "pet";
        throw new Error("abstract");
    }

    protected var _propType :String;
}
}
