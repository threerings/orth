//
// $Id: PlayerInfo.as 19627 2010-11-24 16:02:41Z zell $

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.room.data.ActorInfo;

import com.threerings.util.Joiner;

/**
 * Contains published information about a player in a scene.
 */
public class PlayerInfo extends ActorInfo
    implements PartyOccupantInfo
{
    /**
     * Get the player id for this user, or 0 if they're a guest.
     */
    public function getPlayerId () :int
    {
        return (username as OrthName).getId();
    }

    /**
     * Return the scale that should be used for the media.
     */
    public function getScale () :Number
    {
        return _scale;
    }

    /**
     * Update the scale. This method currently only exists on the actionscript side.  We update the
     * scale immediately when someone is futzing with the scale in the avatar viewer.
     */
    public function setScale (scale :Number) :void
    {
        _scale = scale;
    }

    /**
     * Tests if this player is able to manage the room.
     * Note that this is not a definitive check, but rather one that can be used by clients
     * to check other occupants. The value is computed at the time the occupant enters the
     * room, and is not recomputed even if the room ownership changes. The server should
     * continue to do definitive checks where it matters.
     */
    public function isManager () :Boolean
    {
        return (_flags & MANAGER) != 0;
    }

    /**
     * Returns true if this player is away, false otherwise.
     */
    public function isAway () :Boolean
    {
        return _away;
    }

    // from PartyOccupantInfo
    public function getPartyId () :int
    {
        return _partyId;
    }

    // from ActorInfo
    override public function clone () :Object
    {
        var that :PlayerInfo = super.clone() as PlayerInfo;
        that._scale = this._scale;
        that._partyId = this._partyId;
        that._away = this._away;
        return that;
    }

    // from ActorInfo
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _scale = ins.readFloat();
        _partyId = ins.readInt();
        _away = ins.readBoolean();
    }

    /** @inheritDoc */
    // from SimpleStreamableObject
    override protected function toStringJoiner (j :Joiner): void
    {
        super.toStringJoiner(j);
        j.add("scale", _scale, "partyId", _partyId, "away", _away);
    }

    protected var _scale :Number;
    protected var _partyId :int;
    protected var _away :Boolean;
}
}
