//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.peer.data;

import javax.annotation.Generated;

import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.party.data.MemberParty;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.util.ActionScript;

/**
 * Maintains information on an Orth peer server.
 */
@ActionScript(omit=true)
public class OrthNodeObject extends NodeObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>hostedRooms</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String HOSTED_ROOMS = "hostedRooms";

    /** The field name of the <code>memberParties</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String MEMBER_PARTIES = "memberParties";

    /** The field name of the <code>hostedGuilds</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String HOSTED_GUILDS = "hostedGuilds";
    // AUTO-GENERATED: FIELDS END

    /** Contains info on all places hosted by this server. */
    public DSet<HostedNodelet> hostedRooms = DSet.newDSet();

    /** Contains the current partyId of all members partying on this server. */
    public DSet<MemberParty> memberParties = DSet.newDSet();

    /** Contains the guilds hosted by this server. */
    public DSet<HostedNodelet> hostedGuilds = DSet.newDSet();

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the specified entry be added to the
     * <code>hostedRooms</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToHostedRooms (HostedNodelet elem)
    {
        requestEntryAdd(HOSTED_ROOMS, hostedRooms, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>hostedRooms</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromHostedRooms (Comparable<?> key)
    {
        requestEntryRemove(HOSTED_ROOMS, hostedRooms, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>hostedRooms</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateHostedRooms (HostedNodelet elem)
    {
        requestEntryUpdate(HOSTED_ROOMS, hostedRooms, elem);
    }

    /**
     * Requests that the <code>hostedRooms</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setHostedRooms (DSet<HostedNodelet> value)
    {
        requestAttributeChange(HOSTED_ROOMS, value, this.hostedRooms);
        DSet<HostedNodelet> clone = (value == null) ? null : value.clone();
        this.hostedRooms = clone;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>memberParties</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToMemberParties (MemberParty elem)
    {
        requestEntryAdd(MEMBER_PARTIES, memberParties, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>memberParties</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromMemberParties (Comparable<?> key)
    {
        requestEntryRemove(MEMBER_PARTIES, memberParties, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>memberParties</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateMemberParties (MemberParty elem)
    {
        requestEntryUpdate(MEMBER_PARTIES, memberParties, elem);
    }

    /**
     * Requests that the <code>memberParties</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setMemberParties (DSet<MemberParty> value)
    {
        requestAttributeChange(MEMBER_PARTIES, value, this.memberParties);
        DSet<MemberParty> clone = (value == null) ? null : value.clone();
        this.memberParties = clone;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>hostedGuilds</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToHostedGuilds (HostedNodelet elem)
    {
        requestEntryAdd(HOSTED_GUILDS, hostedGuilds, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>hostedGuilds</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromHostedGuilds (Comparable<?> key)
    {
        requestEntryRemove(HOSTED_GUILDS, hostedGuilds, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>hostedGuilds</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateHostedGuilds (HostedNodelet elem)
    {
        requestEntryUpdate(HOSTED_GUILDS, hostedGuilds, elem);
    }

    /**
     * Requests that the <code>hostedGuilds</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setHostedGuilds (DSet<HostedNodelet> value)
    {
        requestAttributeChange(HOSTED_GUILDS, value, this.hostedGuilds);
        DSet<HostedNodelet> clone = (value == null) ? null : value.clone();
        this.hostedGuilds = clone;
    }
    // AUTO-GENERATED: METHODS END
}
