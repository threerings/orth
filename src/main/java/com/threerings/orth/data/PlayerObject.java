//
// $Id: MemberObject.java 19737 2010-12-05 04:03:42Z zell $

package com.threerings.orth.data;

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
 * Represents a connected orth user.
 */
public class PlayerObject extends ActorObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>partyId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PARTY_ID = "partyId";
    // AUTO-GENERATED: FIELDS END

    /** A message sent by the server to denote a notification to be displayed.
     * Format: [ Notification ]. */
    public static final String NOTIFICATION = "notification";

    /** The name and id information for this user. */
    public OrthName playerName;

    /** The name of the member this member is following or null. */
    public OrthName following;

    /** The names of members following this member. */
    public DSet<OrthName> followers = new DSet<OrthName>();

    /** The avatar that the user has chosen, or null for guests. */
    public EntityIdent avatar;

    /** The online friends of this player. */
    public DSet<FriendEntry> friends = new DSet<FriendEntry>();

    /** If this member is currently walking a pet, the id of the pet being walked, else 0. */
    public int walkingId;

    /** The player's current partyId, or 0 if they're not in a party.
     * Used to signal the PartyDirector. */
    public int partyId;

    /**
     * Convenience method for returning this player's unique id.
     */
    public int getPlayerId ()
    {
        return playerName.getId();
    }

    /**
     * Returns true if this member is away (from the keyboard... sort of), false if they are not.
     */
    public boolean isAway ()
    {
        return awayMessage != null; // message is set to non-null when we're away
    }

    /**
     * Returns true if the specified member is our friend (and online). See MemberLocal for full
     * friend check.
     */
    public boolean isOnlineFriend (int memberId)
    {
        return friends.containsKey(memberId);
    }

    // from interface MsoyUserObject
    public void setParty (PartySummary summary)
    {
        _party = summary;
        int newPartyId = (summary == null) ? 0 : summary.id;
        if (newPartyId != partyId) {
            setPartyId(newPartyId); // avoid generating an extra event when we cross nodes
        }
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

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>partyId</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPartyId (int value)
    {
        int ovalue = this.partyId;
        requestAttributeChange(
            PARTY_ID, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.partyId = value;
    }
    // AUTO-GENERATED: METHODS END

    @Override // from BodyObject
    protected void addWhoData (StringBuilder buf)
    {
        buf.append("mid=").append(playerName.getId()).append(" oid=");
        super.addWhoData(buf);
    }

    /** The user's party summary. Only needed on the server. */
    protected transient PartySummary _party;
}
