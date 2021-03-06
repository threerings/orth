//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.net.Credentials;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class TokenCredentials extends Credentials
{
// GENERATED CLASSDECL END

    public function TokenCredentials (token :String = null)
    {
        this.sessionToken = token;
    }

// GENERATED STREAMING START
    public var sessionToken :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        sessionToken = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(sessionToken);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

