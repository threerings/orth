// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.nodelet.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;
import com.threerings.io.TypedArray;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.nodelet.data.Nodelet;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class HostedNodelet extends SimpleStreamableObject
    implements DSet_Entry
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var nodelet :Nodelet;

    public var host :String;

    public var ports :TypedArray;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        nodelet = ins.readObject(Nodelet);
        host = ins.readField(String);
        ports = ins.readField(TypedArray.getJavaType(int));
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(nodelet);
        out.writeField(host);
        out.writeField(ports);
    }

// GENERATED STREAMING END

    public function getKey () :Object
    {
        return nodelet.getId();
    }
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

