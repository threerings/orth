//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Joiner;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.guild.data.GuildName;
import com.threerings.orth.room.data.ActorInfo;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class SocializerInfo extends ActorInfo
{
// GENERATED CLASSDECL END

    /**
     * Get the player id for this user, or 0 if they're a guest.
     */
    public function get id () :int
    {
        return (username as PlayerName).id;
    }

    /**
     * Return the scale that should be used for the media.
     */
    public function getScale () :Number
    {
        return _scale;
    }

    public function get guild () :GuildName
    {
        return _guild;
    }

    /**
     * Returns true if this player is away, false otherwise.
     */
    public function isAway () :Boolean
    {
        return _away;
    }

    public function getPartyId () :int
    {
        return _partyId;
    }

    // from ActorInfo
    override public function clone () :Object
    {
        var that :SocializerInfo = super.clone() as SocializerInfo;
        that._scale = this._scale;
        that._partyId = this._partyId;
        that._away = this._away;
        return that;
    }

    /** @inheritDoc */
    // from SimpleStreamableObject
    override protected function toStringJoiner (j :Joiner): void
    {
        super.toStringJoiner(j);
        j.add("scale", _scale, "partyId", _partyId, "away", _away);
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _scale = ins.readFloat();
        _guild = ins.readObject(GuildName);
        _partyId = ins.readInt();
        _away = ins.readBoolean();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeFloat(_scale);
        out.writeObject(_guild);
        out.writeInt(_partyId);
        out.writeBoolean(_away);
    }

    protected var _scale :Number;
    protected var _guild :GuildName;
    protected var _partyId :int;
    protected var _away :Boolean;
// GENERATED STREAMING END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
