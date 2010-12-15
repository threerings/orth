//
// $Id: $

package com.threerings.orth.room.data {

import com.threerings.io.ObjectOutputStream;
import com.threerings.io.ObjectInputStream;
import com.threerings.util.ByteEnum;
import com.threerings.util.ComparisonChain;

public class SimpleEntityIdent implements EntityIdent
{
    public static function toString (id :EntityIdent) :String
    {
        return id.getType().toByte() + ":" + id.getItem();
    }

    public static function fromString (str :String):EntityIdent
    {
        var tokens :Array = str.split(":");
        var entityType :EntityType = EntityType(ByteEnum.fromByte(EntityType, tokens[0]));
        var entityId :* = tokens[1];

        return new SimpleEntityIdent(entityType, entityId);
    }

    public function SimpleEntityIdent (type :EntityType, id :int)
    {
        _type = type;
        _id = id;
    }

    // from interface EntityIdent
    public function getType () :EntityType
    {
        return _type;
    }

    // from interface EntityIdent
    public function getItem () :int
    {
        return _id;
    }

    // from interface Equalable
    public function equals (other :Object) :Boolean
    {
        return (other is SimpleEntityIdent)
            && _type == (other as SimpleEntityIdent).getType()
            && _id == (other as SimpleEntityIdent).getItem();
    }

    // from interface Hashable
    public function hashCode () :int
    {
        return (_type.toByte() * 37) | _id;
    }

    // from interface Streamable
    public function readObject (ins :ObjectInputStream) :void
    {
        _type = EntityType(ins.readObject(EntityType));
        _id = ins.readInt();
    }

    // from interface Streamable
    public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeObject(_type);
        out.writeInt(_id);
    }

    // from Comparable
    public function compareTo (other :Object) :int
    {
        return ComparisonChain.start()
            .compareComparables(_type, (other as SimpleEntityIdent).getType())
            .compareInts(_id, (other as SimpleEntityIdent).getItem())
            .result();
    }

    /**
     * Generates a string representation of this instance.
     */
    public function toString () :String
    {
        return _type + ":" + _id;
    }

    protected var _type :EntityType;
    protected var _id :int;
}
}
