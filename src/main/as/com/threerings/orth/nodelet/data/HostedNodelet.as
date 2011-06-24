//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.nodelet.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.data.ServerAddress;
import com.threerings.orth.nodelet.data.Nodelet;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class HostedNodelet extends ServerAddress
    implements DSet_Entry
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var nodelet :Nodelet;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        nodelet = ins.readObject(Nodelet);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(nodelet);
    }

// GENERATED STREAMING END

    public function getKey () :Object
    {
        return nodelet.getId();
    }
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

