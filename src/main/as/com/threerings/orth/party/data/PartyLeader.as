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
public class PartyLeader extends SimpleStreamableObject
    implements DSet_Entry
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var partyId :int;

    public var leaderId :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        partyId = ins.readInt();
        leaderId = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(partyId);
        out.writeInt(leaderId);
    }

// GENERATED STREAMING END

    public function getKey () :Object
    {
        return partyId;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

