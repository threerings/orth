//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.data.where {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.where.Whereabouts;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class Offline extends Whereabouts
{
// GENERATED CLASSDECL END
    override public function getDescription () :String
    {
        return "m.offline";
    }

    override public function isOnline () :Boolean
    {
        return false;
    }

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

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

