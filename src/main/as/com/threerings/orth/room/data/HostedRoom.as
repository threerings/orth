// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.locus.data.HostedLocus;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class HostedRoom extends HostedLocus
    implements DSet_Entry
{
// GENERATED CLASSDECL END

    public function getKey () :Object
    {
        return locus;
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

