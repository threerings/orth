//
// $Id: ActorInfo.java 16914 2009-05-27 05:54:19Z mdb $

package com.threerings.orth.room.data {

import com.threerings.io.ObjectOutputStream;
import com.threerings.io.ObjectInputStream;
import com.threerings.util.ComparisonChain;

public class SimpleEntityIdent implements EntityIdent
{
    public function SimpleEntityIdent (type :int, id :int)
    {
        _type = type;
        _id = id;
    }

    // from interface EntityIdent
    public function getType () :int
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
        return (_type * 37) | _id;
    }

    // from interface Streamable
    public function readObject (ins :ObjectInputStream) :void
    {
        _type = ins.readByte();
        _id = ins.readInt();
    }

    // from interface Streamable
    public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeByte(_type);
        out.writeInt(_id);
    }

    // from Comparable
    public function compareTo (other :Object) :int
    {
        return ComparisonChain.start()
            .compareInts(_type, (other as SimpleEntityIdent).getType())
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

    protected var _type :int;
    protected var _id :int;
}
}
