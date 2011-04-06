// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Comparable;

import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.room.client.RoomModule;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class RoomLocus extends Locus
{
// GENERATED CLASSDECL END

    public function RoomLocus (sceneId :int=0, loc :OrthLocation=null)
    {
        super(RoomModule);
        this.sceneId = sceneId;
        this.loc = loc;
    }

    public var loc :OrthLocation;

    public function compareTo (other:Object):int
    {
        // ORTH TODO: nothing on the AS client actually uses our Comparableness, but there's
        // no way for us to say we don't want the generated streamable not to be Comparable
        throw new Error("Loci aren't comparable in AS");
    }

// GENERATED STREAMING START
    public var sceneId :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        sceneId = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(sceneId);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

