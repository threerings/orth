// GENERATED PREAMBLE START
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
public class MemberParty extends SimpleStreamableObject
    implements DSet_Entry
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var playerId :int;

    public var partyOid :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        playerId = ins.readInt();
        partyOid = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(playerId);
        out.writeInt(partyOid);
    }

// GENERATED STREAMING END

    public function getKey () :Object
    {
        return playerId;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

