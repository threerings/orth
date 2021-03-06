//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.nodelet.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.net.BootstrapData;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class NodeletBootstrapData extends BootstrapData
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var targetOid :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        targetOid = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(targetOid);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

