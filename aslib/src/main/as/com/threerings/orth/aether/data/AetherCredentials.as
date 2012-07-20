//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.aether.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.net.Credentials;
import com.threerings.presents.net.Credentials_HasMachineIdent;

import com.threerings.orth.client.Prefs;

// GENERATED PREAMBLE END

/**
 * Used to authenticate a aether session.
 */
// GENERATED CLASSDECL START
public class AetherCredentials extends Credentials
    implements Credentials_HasMachineIdent
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var ident :String;

    public var name :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        ident = ins.readField(String);
        name = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(ident);
        out.writeField(name);
    }

// GENERATED STREAMING END

    /**
     * Creates credentials with the specified name. Assigns the ident to the value from the user's
     * Prefs.
     */
    public function AetherCredentials (name :String)
    {
        this.name = name;
        this.ident = Prefs.getMachineIdent();
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
