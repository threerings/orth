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
        throw new Error("abstract");
    }

    protected var _propType :String;
}
}
