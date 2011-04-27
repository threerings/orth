// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Comparable;

import com.threerings.orth.locus.data.Locus;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL DISABLED
public class RoomLocus extends Locus
{
    public var loc :OrthLocation;

    public function RoomLocus (sceneId :int=0, loc :OrthLocation=null)
    {
        this.sceneId = sceneId;
        this.loc = loc;
    }

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

    override public function getId () :int
    {
        return sceneId;
    }
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

