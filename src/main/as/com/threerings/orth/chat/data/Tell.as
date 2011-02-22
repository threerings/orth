// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.chat.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.aether.data.PlayerName;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class Tell extends SimpleStreamableObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _from = ins.readObject(PlayerName);
        _message = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_from);
        out.writeField(_message);
    }

    protected var _from :PlayerName;
    protected var _message :String;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

