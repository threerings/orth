// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.PlayerEntry;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class FriendEntry extends PlayerEntry
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var status :String;

    public var online :Boolean;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        status = ins.readField(String);
        online = ins.readBoolean();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(status);
        out.writeBoolean(online);
    }

// GENERATED STREAMING END

    override public function toString () :String
    {
        return "FriendEntry[" + name + "]";
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
