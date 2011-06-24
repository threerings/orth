//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.TokenCredentials;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class RoomCredentials extends TokenCredentials
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
    }

// GENERATED STREAMING END

    public function RoomCredentials (token :String = null)
    {
        super(token);
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

