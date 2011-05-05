//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Joiner;

import com.threerings.orth.data.FriendEntry_Status;
import com.threerings.orth.data.PlayerEntry;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class FriendEntry extends PlayerEntry
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var status :FriendEntry_Status;

    public var statusMessage :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        status = ins.readObject(FriendEntry_Status);
        statusMessage = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(status);
        out.writeField(statusMessage);
    }

// GENERATED STREAMING END

    override public function toString () :String
    {
        return Joiner.simpleToString(this);
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
