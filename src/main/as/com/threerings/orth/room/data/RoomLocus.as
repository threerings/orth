//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.room.data.OrthLocation;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class RoomLocus extends Nodelet
    implements Locus
{
// GENERATED CLASSDECL END
    public function RoomLocus (sceneId :int = 0, loc :OrthLocation = null)
    {
        this.sceneId = sceneId;
        this.loc = loc;
    }

// GENERATED STREAMING START
    public var sceneId :int;

    public var loc :OrthLocation;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        sceneId = ins.readInt();
        loc = ins.readObject(OrthLocation);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(sceneId);
        out.writeObject(loc);
    }

// GENERATED STREAMING END

    override public function getId () :Object
    {
        return sceneId;
    }
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

