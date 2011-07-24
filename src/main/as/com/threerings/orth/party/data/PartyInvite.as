//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.comms.data.OneToOneComm;
import com.threerings.orth.comms.data.RequestComm;
import com.threerings.orth.party.client.PartyDirector;
import com.threerings.orth.party.data.PartyObjectAddress;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyInvite extends BaseOneToOneComm
    implements RequestComm
{
// GENERATED CLASSDECL END
    override public function get toMessage () :String
    {
        return _from + " invited you to their party";
    }

    override public function get fromMessage () :String
    {
        return "You invited " + _to + " to your party";
    }

    public function get acceptMessage () :String
    {
        return "You joined " + _from + "'s party";
    }

    public function get ignoreMessage () :String
    {
        return "You ignored " + _from + "'s party invitation";
    }

    public function onAccepted () :void
    {
        _module.getInstance(PartyDirector).joinParty(address);
    }

// GENERATED STREAMING START
    public var address :PartyObjectAddress;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        address = ins.readObject(PartyObjectAddress);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(address);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

