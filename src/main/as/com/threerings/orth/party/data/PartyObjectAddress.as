//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.ServerAddress;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyObjectAddress extends ServerAddress
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var oid :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        oid = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(oid);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

