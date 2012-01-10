//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.data.where {

import flashx.funk.util.isAbstract;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class Whereabouts extends SimpleStreamableObject
{
// GENERATED CLASSDECL END

    /**
     * Returns a translatable description of the player's whereabouts.
     */
    public function getDescription () :String
    {
        return isAbstract();
    }

    /**
     * Checks whether the player is online.
     */
    public function isOnline () :Boolean
    {
        return isAbstract();
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

