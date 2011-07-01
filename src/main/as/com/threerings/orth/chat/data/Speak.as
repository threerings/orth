//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.chat.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.data.OrthName;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class Speak extends SimpleStreamableObject
{
// GENERATED CLASSDECL END
    public function get from () :OrthName
    {
        return _from;
    }

    public function get message () :String
    {
        return _message;
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _from = ins.readObject(OrthName);
        _message = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_from);
        out.writeField(_message);
    }

    protected var _from :OrthName;
    protected var _message :String;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

