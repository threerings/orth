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
    public function RoomLocus (sceneId :int = 0, instanceId :String = null, loc :OrthLocation = null)
    {
        this.sceneId = sceneId;
        this.instanceId = instanceId;
        this.loc = loc;
    }

// GENERATED STREAMING START
    public var sceneId :int;

    public var instanceId :String;

    public var loc :OrthLocation;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        sceneId = ins.readInt();
        instanceId = ins.readField(String);
        loc = ins.readObject(OrthLocation);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(sceneId);
        out.writeField(instanceId);
        out.writeObject(loc);
    }

// GENERATED STREAMING END

    override public function getId () :Object
    {
        return new Key(this);
    }
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

import com.threerings.util.Equalable;

import com.threerings.orth.room.data.RoomLocus;

class Key implements Equalable
{
    public var instanceId :String;
    public var sceneId :int;

    public function Key (locus :RoomLocus)
    {
        this.instanceId = locus.instanceId;
        this.sceneId = locus.sceneId;
    }

    public function equals (other :Object) :Boolean
    {
        return (other is Key) &&
            this.instanceId == Key(other).instanceId &&
            this.sceneId == Key(other).sceneId;
    }
}
