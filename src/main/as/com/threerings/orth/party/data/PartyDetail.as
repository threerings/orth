//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.TypedArray;
import com.threerings.io.streamers.ArrayStreamer;

import com.threerings.orth.party.data.PartyBoardInfo;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyDetail extends PartyBoardInfo
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var peeps :TypedArray;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        peeps = ins.readField(ArrayStreamer.INSTANCE);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(peeps, ArrayStreamer.INSTANCE);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

