//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.guild.data.GuildName;

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

    /** Used to update our guild info when that changes. */
    public static class GuildUpdater implements Updater<SocializerInfo>
    {
        public GuildUpdater (SocializerObject mobj) {
            _mobj = mobj;
        }
        public boolean update (SocializerInfo info) {
            info.updateGuild(_mobj.guild);
            return true;
        }
        protected SocializerObject _mobj;
    }

    public static class TitleUpdater implements Updater<SocializerInfo>
    {
        public TitleUpdater (SocializerObject mobj) {
            _mobj = mobj;
        }
        public boolean update (SocializerInfo info) {
            info.updateTitle(_mobj.title);
            return true;
        }
        protected SocializerObject _mobj;
    }

    public SocializerInfo (SocializerObject sobj)
    {
        super(sobj);
        // configure our various bits
        _guild = sobj.guild;
        _title = sobj.title;
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
        return ((PlayerName) username).getId();
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

    public void updateGuild (GuildName guild)
    {
        _guild = guild;
    }

    public void updateTitle (String title)
    {
        _title = title;
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

    @Override
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
        buf.append(", party=").append(_partyId).append(", guild=").append(_guild);
    }

    protected float _scale;
    protected GuildName _guild;
    protected int _partyId;
    protected boolean _away;
    protected String _title;
}
