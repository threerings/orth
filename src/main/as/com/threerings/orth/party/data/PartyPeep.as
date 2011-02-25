// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.PlayerEntry;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyPeep extends PlayerEntry
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var joinOrder :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        joinOrder = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(joinOrder);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
