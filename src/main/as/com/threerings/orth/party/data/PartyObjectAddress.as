// GENERATED PREAMBLE START
//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.


package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyObjectAddress extends SimpleStreamableObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var hostName :String;

    public var port :int;

    public var oid :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        hostName = ins.readField(String);
        port = ins.readInt();
        oid = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(hostName);
        out.writeInt(port);
        out.writeInt(oid);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

