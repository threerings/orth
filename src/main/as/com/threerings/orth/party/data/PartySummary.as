// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.data.MediaDesc;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartySummary extends SimpleStreamableObject
    implements DSet_Entry
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var id :int;

    public var name :String;

    public var icon :MediaDesc;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        id = ins.readInt();
        name = ins.readField(String);
        icon = ins.readObject(MediaDesc);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(id);
        out.writeField(name);
        out.writeObject(icon);
    }

// GENERATED STREAMING END

    public function getKey () :Object
    {
        return id;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

