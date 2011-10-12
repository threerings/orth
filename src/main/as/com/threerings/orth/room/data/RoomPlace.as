//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.whirled.data.ScenePlace;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class RoomPlace extends ScenePlace
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var instanceId :String;

    public var name :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        instanceId = ins.readField(String);
        name = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(instanceId);
        out.writeField(name);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

