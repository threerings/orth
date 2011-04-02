// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.net.BootstrapData;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyBootstrapData extends BootstrapData
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var partyOid :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        partyOid = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(partyOid);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

