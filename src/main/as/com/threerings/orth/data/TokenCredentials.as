// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.net.Credentials;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class TokenCredentials extends Credentials
{
// GENERATED CLASSDECL END

    public function TokenCredentials (token :String = null, object :Object = null)
    {
        this.sessionToken = token;
    }

// GENERATED STREAMING START
    public var sessionToken :String;

    public var object :Object;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        sessionToken = ins.readField(String);
        object = ins.readObject(Object);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(sessionToken);
        out.writeObject(object);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

