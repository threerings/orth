// GENERATED PREAMBLE START
//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.


package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.util.Comparable;

import com.threerings.orth.party.data.PartyInfo;
import com.threerings.orth.party.data.PartySummary;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyBoardInfo extends SimpleStreamableObject
    implements Comparable
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var summary :PartySummary;

    public var info :PartyInfo;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        summary = ins.readObject(PartySummary);
        info = ins.readObject(PartyInfo);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(summary);
        out.writeObject(info);
    }

// GENERATED STREAMING END

    public function compareTo (that :Object) :int
    {
        return 0; // TODO(bruno)
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

