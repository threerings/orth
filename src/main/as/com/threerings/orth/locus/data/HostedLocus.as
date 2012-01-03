//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.locus.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.ServerAddress;
import com.threerings.orth.locus.data.Locus;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class HostedLocus extends ServerAddress
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var locus :Locus;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        locus = ins.readObject(Locus);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(locus);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

