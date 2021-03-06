//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import javax.annotation.Generated;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.orth.chat.data.ChannelEntry;
import com.threerings.orth.data.PlayerEntry;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.guild.data.GuildName;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.data.HostedNodelet;

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

    /** The field name of the <code>ignoring</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String IGNORING = "ignoring";

    /** The field name of the <code>ignoredBy</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String IGNORED_BY = "ignoredBy";

    /** The field name of the <code>channels</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String CHANNELS = "channels";

    /** The field name of the <code>locus</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String LOCUS = "locus";

    /** The field name of the <code>party</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PARTY = "party";

    /** The field name of the <code>guildName</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String GUILD_NAME = "guildName";

    /** The field name of the <code>guild</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String GUILD = "guild";
    // AUTO-GENERATED: FIELDS END

    /** The name and id information for this player. */
    public PlayerName playerName;

    /** The online friends of this player. */
    public DSet<PlayerEntry> friends = DSet.newDSet();

    /** The players on our ignore list. */
    public DSet<PlayerName> ignoring; // initialized during resolution

    /** The players who are ignoring us. */
    public DSet<PlayerName> ignoredBy; // initialized during resolution

    /** Our current set of subscribed chat channels. */
    public DSet<ChannelEntry> channels = DSet.newDSet();

    /** Where this player currently is. May be set during client resolution. */
    public Locus locus;

    /** The player's current party, or null if they're not in a party.
     * Used to signal the PartyDirector. */
    public HostedNodelet party;

    /** The id of the guild this player belongs to, or zero if they belong to no guild. */
    public GuildName guildName;

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

    /**
     * Returns true if at least one of the given players is a friend of ours.
     */
    public boolean containsOnlineFriend (Iterable<Integer> playerIds)
    {
        for (int playerId : playerIds) {
            if (friends.containsKey(playerId)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns an orth-appropriate short string identifying this aether client.
     */
    @Override
    public String who ()
    {
        if (playerName != null) {
            return "(" + playerName.toString() + ":" + playerName.getId() + ")";
        }
        return super.who() + " [playerName = null]";
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
    public void setPlayerName (PlayerName value)
    {
        PlayerName ovalue = this.playerName;
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
    public void addToFriends (PlayerEntry elem)
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
    public void updateFriends (PlayerEntry elem)
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
    public void setFriends (DSet<PlayerEntry> value)
    {
        requestAttributeChange(FRIENDS, value, this.friends);
        DSet<PlayerEntry> clone = (value == null) ? null : value.clone();
        this.friends = clone;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>ignoring</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToIgnoring (PlayerName elem)
    {
        requestEntryAdd(IGNORING, ignoring, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>ignoring</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromIgnoring (Comparable<?> key)
    {
        requestEntryRemove(IGNORING, ignoring, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>ignoring</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateIgnoring (PlayerName elem)
    {
        requestEntryUpdate(IGNORING, ignoring, elem);
    }

    /**
     * Requests that the <code>ignoring</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setIgnoring (DSet<PlayerName> value)
    {
        requestAttributeChange(IGNORING, value, this.ignoring);
        DSet<PlayerName> clone = (value == null) ? null : value.clone();
        this.ignoring = clone;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>ignoredBy</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToIgnoredBy (PlayerName elem)
    {
        requestEntryAdd(IGNORED_BY, ignoredBy, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>ignoredBy</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromIgnoredBy (Comparable<?> key)
    {
        requestEntryRemove(IGNORED_BY, ignoredBy, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>ignoredBy</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateIgnoredBy (PlayerName elem)
    {
        requestEntryUpdate(IGNORED_BY, ignoredBy, elem);
    }

    /**
     * Requests that the <code>ignoredBy</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setIgnoredBy (DSet<PlayerName> value)
    {
        requestAttributeChange(IGNORED_BY, value, this.ignoredBy);
        DSet<PlayerName> clone = (value == null) ? null : value.clone();
        this.ignoredBy = clone;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>channels</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToChannels (ChannelEntry elem)
    {
        requestEntryAdd(CHANNELS, channels, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>channels</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromChannels (Comparable<?> key)
    {
        requestEntryRemove(CHANNELS, channels, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>channels</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateChannels (ChannelEntry elem)
    {
        requestEntryUpdate(CHANNELS, channels, elem);
    }

    /**
     * Requests that the <code>channels</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setChannels (DSet<ChannelEntry> value)
    {
        requestAttributeChange(CHANNELS, value, this.channels);
        DSet<ChannelEntry> clone = (value == null) ? null : value.clone();
        this.channels = clone;
    }

    /**
     * Requests that the <code>locus</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setLocus (Locus value)
    {
        Locus ovalue = this.locus;
        requestAttributeChange(
            LOCUS, value, ovalue);
        this.locus = value;
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
    public void setParty (HostedNodelet value)
    {
        HostedNodelet ovalue = this.party;
        requestAttributeChange(
            PARTY, value, ovalue);
        this.party = value;
    }

    /**
     * Requests that the <code>guildName</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setGuildName (GuildName value)
    {
        GuildName ovalue = this.guildName;
        requestAttributeChange(
            GUILD_NAME, value, ovalue);
        this.guildName = value;
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
