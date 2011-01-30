//
// $Id: ActorInfo.as 18101 2009-09-16 21:22:48Z ray $

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.orth.data.MediaDesc;

import com.threerings.util.Joiner;

import com.threerings.crowd.data.OccupantInfo;

/**
 * Contains published information about an actor in a scene (members and pets).
 */
public class ActorInfo extends OccupantInfo
{
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

    // from OccupantInfo
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _media = MediaDesc(ins.readObject());
        _ident = EntityIdent(ins.readObject());
        _state = (ins.readField(String) as String);
    }

    /** @inheritDoc */
    // from SimpleStreamableObject
    override protected function toStringJoiner (j :Joiner): void
    {
        super.toStringJoiner(j);
        j.add("media", _media, "ident", _ident, "state", _state);
    }

    protected var _media :MediaDesc;
    protected var _ident :EntityIdent;
    protected var _state :String;
}
}