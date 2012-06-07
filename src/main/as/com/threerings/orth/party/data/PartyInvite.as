//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.aether.client.AetherDirector;
import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.comms.data.OneToOneComm;
import com.threerings.orth.comms.data.RequestComm;
import com.threerings.orth.nodelet.data.HostedNodelet;

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
        AetherDirector(_module.getInstance(AetherDirector)).joinParty(hosted);
    }

// GENERATED STREAMING START
    public var hosted :HostedNodelet;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        hosted = ins.readObject(HostedNodelet);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(hosted);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

