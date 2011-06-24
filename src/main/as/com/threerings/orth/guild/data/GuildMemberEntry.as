//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.guild.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.PlayerEntry;
import com.threerings.orth.guild.data.GuildRank;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class GuildMemberEntry extends PlayerEntry
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var rank :GuildRank;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        rank = ins.readObject(GuildRank);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(rank);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

