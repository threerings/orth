// GENERATED PREAMBLE START
//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.


package com.threerings.orth.aether.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.OrthName;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PlayerName extends OrthName
{
// GENERATED CLASSDECL END

    /**
     * Create a new PlayerName.
     */
    public function PlayerName (displayName :String = "", memberId :int = 0)
    {
        super(displayName, memberId);
    }


// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

