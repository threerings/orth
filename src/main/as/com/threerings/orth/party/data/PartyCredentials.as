//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.TokenCredentials;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyCredentials extends TokenCredentials
{
// GENERATED CLASSDECL END

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

    /**
     * Gets the party id the player wants to access.
     */
    public function set partyId (id :int) :void
    {
        object = id;
    }
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

