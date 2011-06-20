// GENERATED PREAMBLE START
//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.


package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.comms.data.SourcedComm;
import com.threerings.orth.data.ModuleStreamable;
import com.threerings.orth.party.client.PartyDirector;
import com.threerings.orth.party.data.PartyObjectAddress;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyInvite extends ModuleStreamable
    implements SourcedComm
{
// GENERATED CLASSDECL END

    public function get source() :PlayerName { return _source; }

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
        _source = ins.readObject(PlayerName);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(address);
        out.writeObject(_source);
    }

    protected var _source :PlayerName;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

