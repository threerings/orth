//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.nodelet.data.Nodelet;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyNodelet extends Nodelet
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var partyId :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        partyId = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(partyId);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

