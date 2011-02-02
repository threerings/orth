// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.world.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;
// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class OrthPlace extends SimpleStreamableObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var peer :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        peer = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(peer);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

