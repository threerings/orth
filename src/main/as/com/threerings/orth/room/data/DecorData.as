//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.room.data.Decor;
import com.threerings.orth.ui.ObjectMediaDesc;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class DecorData extends SimpleStreamableObject
    implements Decor
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var type :int;

    public var width :int;

    public var height :int;

    public var depth :int;

    public var horizon :Number;

    public var actorScale :Number;

    public var furniScale :Number;

    public var hideWalls :Boolean;

    public var walkability :ObjectMediaDesc;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        type = ins.readByte();
        width = ins.readShort();
        height = ins.readShort();
        depth = ins.readShort();
        horizon = ins.readFloat();
        actorScale = ins.readFloat();
        furniScale = ins.readFloat();
        hideWalls = ins.readBoolean();
        walkability = ins.readObject(ObjectMediaDesc);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeByte(type);
        out.writeShort(width);
        out.writeShort(height);
        out.writeShort(depth);
        out.writeFloat(horizon);
        out.writeFloat(actorScale);
        out.writeFloat(furniScale);
        out.writeBoolean(hideWalls);
        out.writeObject(walkability);
    }

// GENERATED STREAMING END

    // from Decor
    public function getHorizon () :Number {
        return horizon;
    }

    // from Decor
    public function getDepth () :int {
        return depth;
    }

    // from Decor
    public function getWidth () :int {
        return width;
    }

    // from Decor
    public function getHeight () :int {
        return height;
    }

    // from Decor
    public function getActorScale () :Number {
        return actorScale;
    }

    // from Decor
    public function getFurniScale () :Number {
        return furniScale;
    }

    // from Decor
    public function getDecorType () :int {
        return type;
    }

    // from Decor
    public function doHideWalls () :Boolean {
        return hideWalls;
    }

    // from Decor
    public function getWalkability () :ObjectMediaDesc {
        return walkability;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

