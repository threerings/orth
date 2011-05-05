//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.data {

import com.threerings.whirled.data.ScenePlace;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class RoomPlace extends ScenePlace
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var peer :String;

    public var name :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        peer = ins.readField(String);
        name = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(peer);
        out.writeField(name);
    }

// GENERATED STREAMING END

    public function getPeer () :String
    {
        return peer;
    }

    public function describePlace () :String
    {
        return name;
    }

    public function getPlaceType () :String
    {
        return OrthRoomCodes.ROOM_PLACE_TYPE;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

