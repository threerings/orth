// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Name;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class AuthName extends Name
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _id = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(_id);
    }

    protected var _id :int;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

