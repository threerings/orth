//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.orth.data.OrthName;

/**
 * Contains published information about a player in a room.
 */
public class SocializerInfo extends ActorInfo
    /* implements PartyOccupantInfo */
{
    /** Used to update our avatar info when that changes. */
    public static class AvatarUpdater implements Updater<SocializerInfo>
    {
        public AvatarUpdater (SocializerObject mobj) {
            _mobj = mobj;
        }
        public boolean update (SocializerInfo info) {
            info.updateMedia(_mobj);
            return true;
        }
        protected SocializerObject _mobj;
    }

    public SocializerInfo (SocializerObject sobj)
    {
        super(sobj);
        // configure our various bits
        // updatePartyId(sobj.partyId);
        updateIsAway(sobj);
    }

    /** Used when unserializing. */
    public SocializerInfo ()
    {
    }

    /**
     * Get the player id for this user, or 0 if they're a guest.
     */
    public int getSocializerId ()
    {
        return ((OrthName) username).getId();
    }

    // from PartyOccupantInfo
    public int getPartyId ()
    {
        return _partyId;
    }

    /**
     * Returns true if this player is away, false otherwise.
     */
    public boolean isAway ()
    {
        return _away;
    }

    /**
     * Updates our away status.
     */
    public void updateIsAway (SocializerObject sobj)
    {
        _away = sobj.isAway();
    }

    /**
     * Return the scale that should be used for the media.
     */
    public float getScale ()
    {
        return _scale;
    }

    // from PartyOccupantInfo
    public boolean updatePartyId (int partyId)
    {
        if (partyId != _partyId) {
            _partyId = partyId;
            return true;
        }
        return false;
    }

    public void updateMedia (ActorObject body)
    {
        SocializerObject sobj = (SocializerObject) body;

        // ORTH TODO: Let's decide if we can ever be without an avatar...
        _media = sobj.avatar.getAvatarMedia();
        _ident = sobj.avatar.getIdent();
        _scale = sobj.avatar.getScale();
        _state = sobj.actorState;
    }

    @Override // from SimpleStreamableObject
    protected void toString (StringBuilder buf)
    {
        super.toString(buf);
        buf.append(", scale=").append(_scale).append(", away=").append(_away);
        buf.append(", party=").append(_partyId);
    }

    protected float _scale;
    protected int _partyId;
    protected boolean _away;
}
