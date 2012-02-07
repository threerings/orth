//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.guild.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.aether.client.AetherDirector;
import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.comms.data.RequestComm;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class GuildInviteNotification extends BaseOneToOneComm
    implements RequestComm
{
// GENERATED CLASSDECL END

    override public function get fromMessage () :String
    {
        return "You invite " + _to + " to your guild '" + _guildName + "'.";
    }

    override public function get toMessage () :String
    {
        return _from + " wants you to join their guild '" + _guildName + "'.";
    }

    public function onAccepted () :void
    {
        _module.getInstance(AetherDirector).acceptGuildInvite(_from.id, _guildId);
    }

    public function get acceptMessage () :String
    {
        return "You are now a member of '" + _guildName + "'.";
    }

    public function get ignoreMessage () :String
    {
        return "You declined the intivation to join '" + _guildName + "'.";
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _guildName = ins.readField(String);
        _guildId = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(_guildName);
        out.writeInt(_guildId);
    }

    protected var _guildName :String;
    protected var _guildId :int;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

