//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.dobj.DSet_Entry;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyInfo extends SimpleStreamableObject
    implements DSet_Entry
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var id :int;

    public var leaderId :int;

    public var status :String;

    public var statusType :int;

    public var population :int;

    public var recruitment :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        id = ins.readInt();
        leaderId = ins.readInt();
        status = ins.readField(String);
        statusType = ins.readByte();
        population = ins.readInt();
        recruitment = ins.readByte();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(id);
        out.writeInt(leaderId);
        out.writeField(status);
        out.writeByte(statusType);
        out.writeInt(population);
        out.writeByte(recruitment);
    }

// GENERATED STREAMING END

    public function getKey () :Object
    {
        return id;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

