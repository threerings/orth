// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.TokenCredentials;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class RoomCredentials extends TokenCredentials
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var displayName :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        displayName = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(displayName);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

