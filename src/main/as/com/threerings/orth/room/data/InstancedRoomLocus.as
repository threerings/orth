//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.RoomLocus;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class InstancedRoomLocus extends RoomLocus
{
// GENERATED CLASSDECL END
    public function InstancedRoomLocus (
        instanceId :String = null, sceneId :int = 0, loc :OrthLocation = null)
    {
        super(sceneId, loc);
        this.instanceId = instanceId;
    }

// GENERATED STREAMING START
    public var instanceId :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        instanceId = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(instanceId);
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

import com.threerings.orth.room.data.InstancedRoomLocus;

class Key implements Equalable
{
    public var instanceId :String;
    public var sceneId :int;

    public function Key (locus :InstancedRoomLocus)
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
