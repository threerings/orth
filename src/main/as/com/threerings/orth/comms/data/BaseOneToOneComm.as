//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.comms.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.comms.data.OneToOneComm;
import com.threerings.orth.data.ModuleStreamable;
import com.threerings.orth.data.OrthName;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class BaseOneToOneComm extends ModuleStreamable
    implements OneToOneComm
{
// GENERATED CLASSDECL END

    public function get from() :OrthName { return _from; }

    public function get to() :OrthName { return _to; }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _from = ins.readObject(OrthName);
        _to = ins.readObject(OrthName);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_from);
        out.writeObject(_to);
    }

    protected var _from :OrthName;
    protected var _to :OrthName;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

