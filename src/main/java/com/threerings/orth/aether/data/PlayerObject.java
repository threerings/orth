//
// $Id$

package com.threerings.orth.aether.data;

import javax.annotation.Generated;
import com.threerings.presents.data.ClientObject;

/**
 * The core distributed object representing the location-agnostic aspect of an Orth player.
 */
public class PlayerObject extends ClientObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>playerName</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PLAYER_NAME = "playerName";

    /** The field name of the <code>partyId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PARTY_ID = "partyId";
    // AUTO-GENERATED: FIELDS END

    /** A message sent by the server to denote a notification to be displayed.
     * Format: [ Notification ]. */
    public static final String NOTIFICATION = "notification";

    /** The name and id information for this player. */
    public VizPlayerName playerName;

    /** The name of the member this member is following or null. */
    public OrthName following;

    /** The names of members following this member. */
    public DSet<OrthName> followers = new DSet<OrthName>();

    /** The online friends of this player. */
    public DSet<FriendEntry> friends = new DSet<FriendEntry>();

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
     * Returns true if the specified member is our friend (and online). See MemberLocal for full
     * friend check.
     */
    public boolean isOnlineFriend (int memberId)
    {
        return friends.containsKey(memberId);
    }

    // public void setParty (PartySummary summary)
    // {
    //     _party = summary;
    //     int newPartyId = (summary == null) ? 0 : summary.id;
    //     if (newPartyId != partyId) {
    //         setPartyId(newPartyId); // avoid generating an extra event when we cross nodes
    //     }
    // }

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>playerName</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPlayerName (VizPlayerName value)
    {
        VizPlayerName ovalue = this.playerName;
        requestAttributeChange(
            PLAYER_NAME, value, ovalue);
        this.playerName = value;
    }
    // AUTO-GENERATED: METHODS END

    // /** The user's party summary. Only needed on the server. */
    // protected transient PartySummary _party;
}
