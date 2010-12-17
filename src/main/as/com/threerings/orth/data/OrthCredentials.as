// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.presents.net.Credentials;
import com.threerings.util.Name;
// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class OrthCredentials extends Credentials
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var sessionToken :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        sessionToken = ins.readField(String);
        _username = ins.readObject(Name);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(sessionToken);
        out.writeObject(_username);
    }

    protected var _username :Name;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

