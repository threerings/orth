//
// $Id: MemberObject.java 19737 2010-12-05 04:03:42Z zell $

package com.threerings.orth.room.data;

import javax.annotation.Generated;
import java.util.Set;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.presents.dobj.DSet;
import com.threerings.util.Name;

import com.threerings.orth.data.OrthName;
import com.threerings.orth.entity.data.Avatar;
import com.threerings.orth.party.data.PartySummary;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.OrthSceneModel;
import com.threerings.orth.room.data.SocializerInfo;

/**
 * Represents an Orth player's in-room incarnation.
 */
public class SocializerObject extends ActorObject
{
    /** The display name of this socializer. While this name is not the same as that in
        PlayerObject.playerName, their numerical ID's will always be the same. */
    public OrthName name;

    /** The avatar that the user has chosen, or null for guests. */
    public Avatar avatar;

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
}
