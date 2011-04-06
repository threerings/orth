// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.locus.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;
import com.threerings.io.TypedArray;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.locus.data.Locus;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class HostedLocus extends SimpleStreamableObject
    implements DSet_Entry
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var locus :Locus;

    public var host :String;

    public var ports :TypedArray;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        locus = ins.readObject(Locus);
        host = ins.readField(String);
        ports = ins.readField(TypedArray.getJavaType(int));
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(locus);
        out.writeField(host);
        out.writeField(ports);
    }

// GENERATED STREAMING END

    public function getKey () :Object
    {
        return locus.getId();
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

