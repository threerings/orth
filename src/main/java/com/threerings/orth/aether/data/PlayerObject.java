//
// $Id$

package com.threerings.orth.aether.data;

import javax.annotation.Generated;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.data.OrthPlayer;
import com.threerings.orth.party.data.PartySummary;

/**
 * The core distributed object representing the location-agnostic aspect of an Orth player.
 */
public class PlayerObject extends ClientObject
    implements OrthPlayer
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>playerName</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PLAYER_NAME = "playerName";

    /** The field name of the <code>following</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String FOLLOWING = "following";

    /** The field name of the <code>followers</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String FOLLOWERS = "followers";

    /** The field name of the <code>friends</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String FRIENDS = "friends";

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
    public PlayerName following;

    /** The names of members following this member. */
    public DSet<PlayerName> followers = new DSet<PlayerName>();

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

    // from OrthPlayer
    public DObject self ()
    {
        return this;
    }

    // from OrthPlayer
    public PlayerName getPlayerName ()
    {
        return playerName;
    }

    /**
     * Returns true if the specified member is our friend (and online). See MemberLocal for full
     * friend check.
     */
    public boolean isOnlineFriend (int memberId)
    {
        return friends.containsKey(memberId);
    }

    public PartySummary getParty ()
    {
        return _party;
    }

    public void setParty (PartySummary summary)
    {
        _party = summary;
        int newPartyId = (summary == null) ? 0 : summary.id;
        if (newPartyId != partyId) {
            setPartyId(newPartyId); // avoid generating an extra event when we cross nodes
        }
    }

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

    /**
     * Requests that the <code>following</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setFollowing (PlayerName value)
    {
        PlayerName ovalue = this.following;
        requestAttributeChange(
            FOLLOWING, value, ovalue);
        this.following = value;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>followers</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToFollowers (PlayerName elem)
    {
        requestEntryAdd(FOLLOWERS, followers, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>followers</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromFollowers (Comparable<?> key)
    {
        requestEntryRemove(FOLLOWERS, followers, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>followers</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateFollowers (PlayerName elem)
    {
        requestEntryUpdate(FOLLOWERS, followers, elem);
    }

    /**
     * Requests that the <code>followers</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setFollowers (DSet<PlayerName> value)
    {
        requestAttributeChange(FOLLOWERS, value, this.followers);
        DSet<PlayerName> clone = (value == null) ? null : value.clone();
        this.followers = clone;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>friends</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToFriends (FriendEntry elem)
    {
        requestEntryAdd(FRIENDS, friends, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>friends</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromFriends (Comparable<?> key)
    {
        requestEntryRemove(FRIENDS, friends, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>friends</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateFriends (FriendEntry elem)
    {
        requestEntryUpdate(FRIENDS, friends, elem);
    }

    /**
     * Requests that the <code>friends</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setFriends (DSet<FriendEntry> value)
    {
        requestAttributeChange(FRIENDS, value, this.friends);
        DSet<FriendEntry> clone = (value == null) ? null : value.clone();
        this.friends = clone;
    }

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

    /** The user's party summary. Only needed on the server. */
    protected transient PartySummary _party;
}
