//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.PlayerEntry;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyPeep extends PlayerEntry
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var joinOrder :int;

    public var connected :Boolean;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        joinOrder = ins.readInt();
        connected = ins.readBoolean();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(joinOrder);
        out.writeBoolean(connected);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

