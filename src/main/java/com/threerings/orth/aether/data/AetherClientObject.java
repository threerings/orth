//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import javax.annotation.Generated;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.party.data.PartyObjectAddress;

/**
 * The core distributed object representing the location-agnostic aspect of an Orth player.
 */
public class AetherClientObject extends ClientObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>playerName</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PLAYER_NAME = "playerName";

    /** The field name of the <code>friends</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String FRIENDS = "friends";

    /** The field name of the <code>party</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PARTY = "party";

    /** The field name of the <code>guildId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String GUILD_ID = "guildId";

    /** The field name of the <code>guild</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String GUILD = "guild";
    // AUTO-GENERATED: FIELDS END

    /** A message sent by the server to denote a notification to be displayed.
     * Format: [ Notification ]. */
    public static final String NOTIFICATION = "notification";

    /** The name and id information for this player. */
    public VizPlayerName playerName;

    /** The online friends of this player. */
    public DSet<FriendEntry> friends = new DSet<FriendEntry>();

    /** The player's current party, or null if they're not in a party.
     * Used to signal the PartyDirector. */
    public PartyObjectAddress party;

    /** The id of the guild this player belongs to, or zero if they belong to no guild. */
    public int guildId;

    /** The hosted guild. This may be null if the player is not in a guild or if the guild has
     * not yet been hosted on any server. */
    public HostedNodelet guild;

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
     * Requests that the <code>party</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setParty (PartyObjectAddress value)
    {
        PartyObjectAddress ovalue = this.party;
        requestAttributeChange(
            PARTY, value, ovalue);
        this.party = value;
    }

    /**
     * Requests that the <code>guildId</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setGuildId (int value)
    {
        int ovalue = this.guildId;
        requestAttributeChange(
            GUILD_ID, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.guildId = value;
    }

    /**
     * Requests that the <code>guild</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setGuild (HostedNodelet value)
    {
        HostedNodelet ovalue = this.guild;
        requestAttributeChange(
            GUILD, value, ovalue);
        this.guild = value;
    }
    // AUTO-GENERATED: METHODS END
}