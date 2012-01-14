//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.aether.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.data.where.Whereabouts;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PeeredPlayerInfo extends SimpleStreamableObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var authName :AetherAuthName;

    public var visibleName :PlayerName;

    public var whereabouts :Whereabouts;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        authName = ins.readObject(AetherAuthName);
        visibleName = ins.readObject(PlayerName);
        whereabouts = ins.readObject(Whereabouts);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(authName);
        out.writeObject(visibleName);
        out.writeObject(whereabouts);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

