// GENERATED PREAMBLE START
//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.


package com.threerings.orth.aether.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Joiner;
import com.threerings.util.Name;

import com.threerings.presents.net.UsernamePasswordCreds;

// GENERATED PREAMBLE END

/**
 * Used to authenticate a aether session.
 */
// GENERATED CLASSDECL START
public class AetherCredentials extends UsernamePasswordCreds
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var ident :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        ident = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(ident);
    }

// GENERATED STREAMING END

    /**
     * Creates credentials with the specified username and password. The other public fields should
     * be set before logging in.
     */
    public function AetherCredentials (username :Name, password :String = null)
    {
        super(username);

        _password = password;
    }

    // documentation inherited
    override protected function toStringJoiner (j :Joiner) :void
    {
        super.toStringJoiner(j);
        j.add("password", _password);
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
