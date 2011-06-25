//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.data.Nodelet;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class RoomLocus extends Nodelet
    implements Locus
{
// GENERATED CLASSDECL END
    public var loc :OrthLocation;

    public function RoomLocus (sceneId :int=0, loc :OrthLocation=null)
    {
        this.sceneId = sceneId;
        this.loc = loc;
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

