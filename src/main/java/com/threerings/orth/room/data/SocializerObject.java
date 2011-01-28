//
// $Id: MemberObject.java 19737 2010-12-05 04:03:42Z zell $

package com.threerings.orth.room.data;

import javax.annotation.Generated;
import java.util.Set;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.presents.dobj.DSet;
import com.threerings.util.Name;

import com.threerings.orth.party.data.PartySummary;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.OrthSceneModel;

/**
 * Represents an Orth player's in-room incarnation.
 */
public class SocializerObject extends ActorObject
{
    /** The avatar that the user has chosen, or null for guests. */
    public EntityIdent avatar;

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
        return avatar;
    }

    // from ActorObject
    public boolean canEnterScene (
        int sceneId, int ownerId, byte ownerType, byte accessControl, Set<Integer> friendIds)
    {
        boolean hasRights = false;

        if (ownerType == OrthSceneModel.OWNER_TYPE_MEMBER) {
            switch (accessControl) {
            case OrthSceneModel.ACCESS_EVERYONE: hasRights = true; break;
            case OrthSceneModel.ACCESS_OWNER_ONLY: hasRights = (getPlayerId() == ownerId); break;
            case OrthSceneModel.ACCESS_OWNER_AND_FRIENDS:
                hasRights = (getPlayerId() == ownerId) ||
                   ((friendIds != null) && friendIds.contains(ownerId));
                break;
            }
        }

        return hasRights;
    }

    @Override // from BodyObject
    public OccupantInfo createOccupantInfo (PlaceObject plobj)
    {
        return new PlayerInfo(this);
    }

    @Override // from BodyObject
    public Name getVisibleName ()
    {
        return playerName;
    }

    @Override // from BodyObject
    protected void addWhoData (StringBuilder buf)
    {
        buf.append("mid=").append(playerName.getId()).append(" oid=");
        super.addWhoData(buf);
    }
}
