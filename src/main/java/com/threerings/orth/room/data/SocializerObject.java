//
// $Id: MemberObject.java 19737 2010-12-05 04:03:42Z zell $

package com.threerings.orth.room.data;

import javax.annotation.Generated;
import java.util.Set;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.presents.dobj.DSet;
import com.threerings.util.Name;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.world.data.OrthPlayerBody;
import com.threerings.orth.entity.data.Avatar;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.OrthSceneModel;
import com.threerings.orth.room.data.RoomPlace;
import com.threerings.orth.room.data.SocializerInfo;

/**
 * Represents an Orth player's in-room incarnation.
 */
public class SocializerObject extends ActorObject
    implements OrthPlayerBody
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>name</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String NAME = "name";

    /** The field name of the <code>avatar</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String AVATAR = "avatar";

    /** The field name of the <code>avatarCache</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String AVATAR_CACHE = "avatarCache";

    /** The field name of the <code>walkingId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String WALKING_ID = "walkingId";
    // AUTO-GENERATED: FIELDS END

    /** The display name of this socializer. While this name is not the same as that in
        PlayerObject.playerName, their numerical ID's will always be the same. */
    public PlayerName name;

    /** The avatar that the user has chosen, or null for guests. */
    public Avatar avatar;

    /** A cache of the user's 5 most recently touched avatars. */
    public DSet<Avatar> avatarCache;

    /** If this member is currently walking a pet, the id of the pet being walked, else 0. */
    public int walkingId;

    /**
     * Returns true if this member is away (from the keyboard... sort of), false if they are not.
     */
    public boolean isAway ()
    {
        return awayMessage != null; // message is set to non-null when we're away
    }

    // from ActorObject
    @Override public EntityIdent getEntityIdent ()
    {
        return avatar.getIdent();
    }

    // from ActorObject
    public boolean canEnterScene (
        int sceneId, int ownerId, byte ownerType, byte accessControl, Set<Integer> friendIds)
    {
        boolean hasRights = false;
        int playerId = name.getId();

        if (ownerType == OrthSceneModel.OWNER_TYPE_MEMBER) {
            switch (accessControl) {
            case OrthSceneModel.ACCESS_EVERYONE: hasRights = true; break;
            case OrthSceneModel.ACCESS_OWNER_ONLY: hasRights = (playerId == ownerId); break;
            case OrthSceneModel.ACCESS_OWNER_AND_FRIENDS:
                hasRights = (playerId == ownerId) ||
                   ((friendIds != null) && friendIds.contains(ownerId));
                break;
            }
        }

        return hasRights;
    }

    // from OrthPlayerBody
    public SocializerObject self ()
    {
        return this;
    }

    // from OrthPlayerBody
    public RoomPlace getPlace ()
    {
        return (RoomPlace) location;
    }

    public int getPlayerId ()
    {
        return name.getId();
    }

    @Override // from BodyObject
    public OccupantInfo createOccupantInfo (PlaceObject plobj)
    {
        return new SocializerInfo(this);
    }

    @Override // from BodyObject
    public Name getVisibleName ()
    {
        return name;
    }

    @Override // from BodyObject
    protected void addWhoData (StringBuilder buf)
    {
        buf.append("mid=").append(name.getId()).append(" oid=");
        super.addWhoData(buf);
    }

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>name</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setName (PlayerName value)
    {
        PlayerName ovalue = this.name;
        requestAttributeChange(
            NAME, value, ovalue);
        this.name = value;
    }

    /**
     * Requests that the <code>avatar</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setAvatar (Avatar value)
    {
        Avatar ovalue = this.avatar;
        requestAttributeChange(
            AVATAR, value, ovalue);
        this.avatar = value;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>avatarCache</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToAvatarCache (Avatar elem)
    {
        requestEntryAdd(AVATAR_CACHE, avatarCache, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>avatarCache</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromAvatarCache (Comparable<?> key)
    {
        requestEntryRemove(AVATAR_CACHE, avatarCache, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>avatarCache</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateAvatarCache (Avatar elem)
    {
        requestEntryUpdate(AVATAR_CACHE, avatarCache, elem);
    }

    /**
     * Requests that the <code>avatarCache</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setAvatarCache (DSet<Avatar> value)
    {
        requestAttributeChange(AVATAR_CACHE, value, this.avatarCache);
        DSet<Avatar> clone = (value == null) ? null : value.clone();
        this.avatarCache = clone;
    }

    /**
     * Requests that the <code>walkingId</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setWalkingId (int value)
    {
        int ovalue = this.walkingId;
        requestAttributeChange(
            WALKING_ID, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.walkingId = value;
    }
    // AUTO-GENERATED: METHODS END
}
