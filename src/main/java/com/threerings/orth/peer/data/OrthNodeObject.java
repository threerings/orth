//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.peer.data;

import javax.annotation.Generated;

import com.threerings.util.ActionScript;

import com.threerings.presents.dobj.DSet;
import com.threerings.presents.peer.data.NodeObject;

import com.threerings.orth.instance.data.InstanceInfo;
import com.threerings.orth.nodelet.data.HostedNodelet;

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

    /** The field name of the <code>hostedGuilds</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String HOSTED_GUILDS = "hostedGuilds";

    /** The field name of the <code>instances</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String INSTANCES = "instances";
    // AUTO-GENERATED: FIELDS END

    /** Contains info on all places hosted by this server. */
    public DSet<HostedNodelet> hostedRooms = DSet.newDSet();

    /** Contains the guilds hosted by this server. */
    public DSet<HostedNodelet> hostedGuilds = DSet.newDSet();

    /** Contains the instances hosted by this server. */
    public DSet<InstanceInfo> instances = DSet.newDSet();

    /** The default implementation of a node's load is simply its client count. */
    public float calculateLoad ()
    {
        return clients.size();
    }

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

    /**
     * Requests that the specified entry be added to the
     * <code>instances</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToInstances (InstanceInfo elem)
    {
        requestEntryAdd(INSTANCES, instances, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>instances</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromInstances (Comparable<?> key)
    {
        requestEntryRemove(INSTANCES, instances, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>instances</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateInstances (InstanceInfo elem)
    {
        requestEntryUpdate(INSTANCES, instances, elem);
    }

    /**
     * Requests that the <code>instances</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setInstances (DSet<InstanceInfo> value)
    {
        requestAttributeChange(INSTANCES, value, this.instances);
        DSet<InstanceInfo> clone = (value == null) ? null : value.clone();
        this.instances = clone;
    }
    // AUTO-GENERATED: METHODS END
}
