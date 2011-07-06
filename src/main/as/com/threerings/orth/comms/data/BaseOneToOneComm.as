//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.comms.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.comms.data.OneToOneComm;
import com.threerings.orth.data.ModuleStreamable;
import com.threerings.orth.data.PlayerName;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class BaseOneToOneComm extends ModuleStreamable
    implements OneToOneComm
{
// GENERATED CLASSDECL END
    public function get fromMessage () :String { throw new Error("Abstract!"); }
    public function get from() :PlayerName { return _from; }

    public function get toMessage () :String { throw new Error("Abstract!"); }
    public function get to() :PlayerName { return _to; }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _from = ins.readObject(PlayerName);
        _to = ins.readObject(PlayerName);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_from);
        out.writeObject(_to);
    }

    protected var _from :PlayerName;
    protected var _to :PlayerName;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

