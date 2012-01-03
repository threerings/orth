//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.room.data.ActorInfo;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class PetInfo extends ActorInfo
{
// GENERATED CLASSDECL END

    // statically reference classes we require
    PetName;

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

    // from ActorInfo
    override public function clone () :Object
    {
        var that :PetInfo = super.clone() as PetInfo;
        // presently: nothing else to copy
        return that;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
