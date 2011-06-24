//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.aether.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.data.MediaDesc;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class VizPlayerName extends PlayerName
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _photo = ins.readObject(MediaDesc);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_photo);
    }

    protected var _photo :MediaDesc;
// GENERATED STREAMING END

    public function getPhoto () :MediaDesc
    {
        return _photo;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

