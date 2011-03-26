// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.locus.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class Locus extends SimpleStreamableObject
{
// GENERATED CLASSDECL END

    public var moduleClass :Class;

    public function Locus (moduleClass :Class)
    {
        this.moduleClass = moduleClass;
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

