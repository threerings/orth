// GENERATED PREAMBLE START
//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.


package com.threerings.orth.nodelet.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class Nodelet extends SimpleStreamableObject
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

    /**
     * Gets a unique identifier for this locus, used as a dset key.
     */
    public function getId () :int
    {
        throw new Error("abstract");
    }
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

