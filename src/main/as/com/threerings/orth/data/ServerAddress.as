//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;
import com.threerings.io.TypedArray;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class ServerAddress extends SimpleStreamableObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var host :String;

    public var ports :TypedArray;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        host = ins.readField(String);
        ports = ins.readField(TypedArray.getJavaType(int));
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(host);
        out.writeField(ports);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

