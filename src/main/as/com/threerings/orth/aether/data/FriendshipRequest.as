//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.aether.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.aether.client.FriendDirector;
import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.comms.data.RequestComm;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class FriendshipRequest extends BaseOneToOneComm
    implements RequestComm
{
// GENERATED CLASSDECL END
    override public function get fromMessage () :String
    {
        return "You asked " + _to + " to be your friend";
    }

    override public function get toMessage () :String
    {
        return _from + " would like to be friends";
    }

    public function get acceptMessage () :String
    {
        return _from + " is now your friend";
    }

    public function get ignoreMessage () :String
    {
        return "You ignored " + _from + "'s friend request";
    }

    public function onAccepted () :void
    {
        _module.getInstance(FriendDirector).acceptFriendInvite(_from.id);
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

