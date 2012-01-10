//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.data.where {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.where.Whereabouts;
import com.threerings.orth.locus.data.Locus;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class InLocus extends Whereabouts
{
// GENERATED CLASSDECL END

    override public function getDescription () :String
    {
        return description;
    }

    override public function isOnline () :Boolean
    {
        return true;
    }

// GENERATED STREAMING START
    public var locus :Locus;

    public var description :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        locus = ins.readObject(Locus);
        description = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(locus);
        out.writeField(description);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

