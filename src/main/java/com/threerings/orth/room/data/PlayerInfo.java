//
// $Id: MemberInfo.java 19640 2010-11-28 22:24:27Z zell $

package com.threerings.orth.room.data;

import com.threerings.orth.data.OrthName;
import com.threerings.orth.data.PlayerObject;
import com.threerings.orth.party.data.PartyOccupantInfo;

/**
 * Contains published information about a member in a scene.
 */
public class PlayerInfo extends ActorInfo
    implements PartyOccupantInfo
{
    /** Used to update our avatar info when that changes. */
    public static class AvatarUpdater implements Updater<PlayerInfo>
    {
        public AvatarUpdater (PlayerObject mobj) {
            _mobj = mobj;
        }
        public boolean update (PlayerInfo info) {
            info.updateMedia(_mobj);
            return true;
        }
        protected PlayerObject _mobj;
    }

    public PlayerInfo (PlayerObject plobj)
    {
        super(plobj); // we'll fill these in later

        // configure our various bits
        updatePartyId(plobj.partyId);
        updateIsAway(plobj);
    }

    /** Used for unserialization. */
    public PlayerInfo ()
    {
    }

    /**
     * Get the player id for this user, or 0 if they're a guest.
     */
    public int getPlayerId ()
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
    public void updateIsAway (PlayerObject plobj)
    {
        _away = plobj.isAway();
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

    @Override // from ActorInfo
    protected void useStaticMedia ()
    {
        _media = Avatar.getStaticImageAvatarMedia();
        _ident = new ItemIdent(MsoyItemType.OCCUPANT, getBodyOid());
        _scale = 1f;
    }

    @Override // from ActorInfo
    protected void useDynamicMedia (MsoyBodyObject body)
    {
        PlayerObject plobj = (PlayerObject)body;
        configureAvatar(plobj.avatar, (plobj.isViewer() || plobj.isPermaguest()));
        if (plobj.avatar != null) {
            _media = plobj.avatar.avatarMedia;
            _ident = plobj.avatar.getIdent();
            _scale = plobj.avatar.scale;
        } else {
            _media = (plobj.isViewer() || plobj.isPermaguest()) ?
                Avatar.getDefaultGuestAvatarMedia() : Avatar.getDefaultPlayerAvatarMedia();
            _ident = new ItemIdent(MsoyItemType.OCCUPANT, getBodyOid());
            _scale = 1f;
        }
        _state = plobj.getActorState();
    }

    // TODO: presently exposed to allow for puppets
    public void configureAvatar (Avatar avatar, boolean guestDefault)
    {
        if (avatar != null) {
            _media = avatar.avatarMedia;
            _ident = avatar.getIdent();
            _scale = avatar.scale;
        } else {
            _media = guestDefault ?
                Avatar.getDefaultGuestAvatarMedia() : Avatar.getDefaultPlayerAvatarMedia();
            _ident = new ItemIdent(MsoyItemType.OCCUPANT, getBodyOid());
            _scale = 1f;
        }
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
