//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Integer;
import com.threerings.util.Name;

/**
 * Uniquely identifies a pet, so that they may be muted.
 */
public class PetName extends Name
{
    public function PetName (displayName :String = "", petId :int = 0, ownerId :int = 0)
    {
        super(displayName);
        _petId = petId;
        _ownerId = ownerId;
    }

    public function getPetId () :int
    {
        return _petId;
    }

    public function getOwnerId () :int
    {
        return _ownerId;
    }

    override public function hashCode () :int
    {
        return _petId;
    }

    override public function equals (other :Object) :Boolean
    {
        return (other is PetName) && ((other as PetName)._petId == _petId);
    }

    override public function compareTo (o :Object) :int
    {
        return Integer.compare(_petId, (o as PetName)._petId);
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _petId = ins.readInt();
        _ownerId = ins.readInt();
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(_petId);
        out.writeInt(_ownerId);
    }

    override protected function normalize (name :String) :String
    {
        return name; // do not adjust
    }

    protected var _petId :int;
    protected var _ownerId :int;
}
}
