//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data {

import flashx.funk.util.isAbstract;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;
import com.threerings.io.Streamable;

import com.threerings.orth.data.MediaDesc;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class BasicMediaDesc extends SimpleStreamableObject
    implements MediaDesc
{
// GENERATED CLASSDECL END

    public function getMimeType () :int
    {
        return _mimeType;
    }

    public function equals (other :Object) :Boolean
    {
        return isAbstract();
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _mimeType = ins.readByte();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeByte(_mimeType);
    }

    protected var _mimeType :int;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

