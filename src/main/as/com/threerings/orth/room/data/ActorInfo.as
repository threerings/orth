//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data {

import com.threerings.crowd.data.OccupantInfo;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Joiner;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.data.EntityIdent;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class ActorInfo extends OccupantInfo
{
// GENERATED CLASSDECL END
    /**
     * Returns the media that is used to display this actor.
     */
    public function getMedia () :MediaDesc
    {
        return _media;
    }

    /**
     * Returns the item identifier that is used to identify this actor.
     */
    public function getEntityIdent () :EntityIdent
    {
        return _ident;
    }

    /**
     * Return the current state of the actor, which may be null.
     */
    public function getState () :String
    {
        return _state;
    }

    /**
     * Returns true if this actor is idle.
     */
    public function isIdle () :Boolean
    {
        return (status == OccupantInfo.IDLE);
    }

    override public function clone () :Object
    {
        var that :ActorInfo = super.clone() as ActorInfo;
        that._media = this._media;
        that._ident = this._ident;
        that._state = this._state;
        return that;
    }

    /** @inheritDoc */
    // from SimpleStreamableObject
    override protected function toStringJoiner (j :Joiner): void
    {
        super.toStringJoiner(j);
        j.add("media", _media, "ident", _ident, "state", _state);
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _media = ins.readObject(MediaDesc);
        _ident = ins.readObject(EntityIdent);
        _state = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_media);
        out.writeObject(_ident);
        out.writeField(_state);
    }

    protected var _media :MediaDesc;
    protected var _ident :EntityIdent;
    protected var _state :String;
// GENERATED STREAMING END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
