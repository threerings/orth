//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.notify.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Name;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.notify.data.Notification;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class GuildInviteNotification extends Notification
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _sender = ins.readObject(PlayerName);
        _guildName = ins.readField(String);
        _guildId = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_sender);
        out.writeField(_guildName);
        out.writeInt(_guildId);
    }

    protected var _sender :PlayerName;
    protected var _guildName :String;
    protected var _guildId :int;
// GENERATED STREAMING END

    override public function getSender () :Name
    {
        return _sender;
    }

    /**
     * Gets the player that sent the invite.
     */
    public function getPlayerSender () :PlayerName
    {
        return _sender;
    }

    /**
     * Gets the name of the guild the invite is for.
     */
    public function getGuildName () :String
    {
        return _guildName;
    }

    /**
     * Gets the id of the guild the invite is for.
     */
    public function getGuildId () :int
    {
        return _guildId;
    }
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

