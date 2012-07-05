//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.ByteEnum;
import com.threerings.util.ComparisonChain;

import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityType;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class SimpleEntityIdent implements EntityIdent
{
// GENERATED CLASSDECL END

    public static function toString (id :EntityIdent) :String
    {
        return id.getType().toByte() + ":" + id.getItem();
    }

    public static function fromString (str :String) :EntityIdent
    {
        var tokens :Array = str.split(":");
        var entityType :EntityType = EntityType(ByteEnum.fromByte(EntityType, tokens[0]));
        var entityId :* = tokens[1];

        return new SimpleEntityIdent(entityType, entityId);
    }

    public function SimpleEntityIdent (type :EntityType = null, id :int = 0)
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

// GENERATED STREAMING START
    public function readObject (ins :ObjectInputStream) :void
    {
        _type = ins.readObject(EntityType);
        _id = ins.readInt();
    }

    public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeObject(_type);
        out.writeInt(_id);
    }

    protected var _type :EntityType;
    protected var _id :int;
// GENERATED STREAMING END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
