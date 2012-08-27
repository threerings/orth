//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.chat.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.comms.data.ToOneComm;
import com.threerings.orth.data.ModuleStreamable;
import com.threerings.orth.data.PlayerName;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class Message extends ModuleStreamable
    implements ToOneComm
{
// GENERATED CLASSDECL END
    public function get toMessage () :String
    {
        return _message;
    }

    public function get to () :PlayerName
    {
        return _to;
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _to = ins.readObject(PlayerName);
        _message = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_to);
        out.writeField(_message);
    }

    protected var _to :PlayerName;
    protected var _message :String;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

