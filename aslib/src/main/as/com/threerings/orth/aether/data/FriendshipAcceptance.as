//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.aether.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.comms.data.BaseOneToOneComm;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class FriendshipAcceptance extends BaseOneToOneComm
{
// GENERATED CLASSDECL END
    override public function get fromMessage () :String
    {
        return _to + " accepted your friend request";
    }

    override public function get toMessage () :String
    {
        return "You accepted " + _from + "'s friend request";
    }

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
}
}
// GENERATED CLASSFINISH END

