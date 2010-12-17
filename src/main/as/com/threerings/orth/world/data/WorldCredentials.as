// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.world.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.orth.data.OrthCredentials;

// GENERATED PREAMBLE END

import com.threerings.util.Name;

// GENERATED CLASSDECL START
public class WorldCredentials extends OrthCredentials
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



// GENERATED CLASSFINISH START
    public function WorldCredentials (username :Name, sessionToken :String)
    {
        super(username);
        this.sessionToken = sessionToken;
    }
}
}
// GENERATED CLASSFINISH END
