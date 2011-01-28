//
// $Id: PlayerInfo.as 19627 2010-11-24 16:02:41Z zell $

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.party.data.PartyOccupantInfo;
import com.threerings.orth.room.data.ActorInfo;

import com.threerings.util.Joiner;

/**
 * Contains published information about a player in a scene.
 */
public class SocializerInfo extends ActorInfo
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
        var that :SocializerInfo = super.clone() as SocializerInfo;
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
