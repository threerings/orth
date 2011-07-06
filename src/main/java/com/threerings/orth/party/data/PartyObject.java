//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import java.util.Set;

import javax.annotation.Generated;

import com.google.common.collect.Sets;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.data.HostedLocus;

public class PartyObject extends DObject
    implements Cloneable
{
    public transient final Set<Integer> invitedIds = Sets.newHashSet();

    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>peeps</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PEEPS = "peeps";

    /** The field name of the <code>leaderId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String LEADER_ID = "leaderId";

    /** The field name of the <code>status</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String STATUS = "status";

    /** The field name of the <code>statusType</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String STATUS_TYPE = "statusType";

    /** The field name of the <code>recruitment</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String RECRUITMENT = "recruitment";

    /** The field name of the <code>disband</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String DISBAND = "disband";

    /** The field name of the <code>partyService</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PARTY_SERVICE = "partyService";

    /** The field name of the <code>locus</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String LOCUS = "locus";
    // AUTO-GENERATED: FIELDS END

    /** The list of people in this party. */
    public DSet<PartyPeep> peeps = DSet.newDSet();

    /** The player ID of the current leader. */
    public int leaderId;

    /** Customizable flavor text. */
    public String status;

    /** Helps interpret the status. */
    public byte statusType;

    /** This party's access control. @see PartyCodes */
    public byte recruitment;

    /** Do we disband when the leader leaves? */
    public boolean disband = true;

    /** The service for doing things on this party. */
    public PartyMarshaller partyService;

    /** The shared locus the party is in, or null if they're in disparate locations */
    public HostedLocus locus;

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the specified entry be added to the
     * <code>peeps</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToPeeps (PartyPeep elem)
    {
        requestEntryAdd(PEEPS, peeps, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>peeps</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromPeeps (Comparable<?> key)
    {
        requestEntryRemove(PEEPS, peeps, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>peeps</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updatePeeps (PartyPeep elem)
    {
        requestEntryUpdate(PEEPS, peeps, elem);
    }

    /**
     * Requests that the <code>peeps</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPeeps (DSet<PartyPeep> value)
    {
        requestAttributeChange(PEEPS, value, this.peeps);
        DSet<PartyPeep> clone = (value == null) ? null : value.clone();
        this.peeps = clone;
    }

    /**
     * Requests that the <code>leaderId</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setLeaderId (int value)
    {
        int ovalue = this.leaderId;
        requestAttributeChange(
            LEADER_ID, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.leaderId = value;
    }

    /**
     * Requests that the <code>status</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setStatus (String value)
    {
        String ovalue = this.status;
        requestAttributeChange(
            STATUS, value, ovalue);
        this.status = value;
    }

    /**
     * Requests that the <code>statusType</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setStatusType (byte value)
    {
        byte ovalue = this.statusType;
        requestAttributeChange(
            STATUS_TYPE, Byte.valueOf(value), Byte.valueOf(ovalue));
        this.statusType = value;
    }

    /**
     * Requests that the <code>recruitment</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setRecruitment (byte value)
    {
        byte ovalue = this.recruitment;
        requestAttributeChange(
            RECRUITMENT, Byte.valueOf(value), Byte.valueOf(ovalue));
        this.recruitment = value;
    }

    /**
     * Requests that the <code>disband</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setDisband (boolean value)
    {
        boolean ovalue = this.disband;
        requestAttributeChange(
            DISBAND, Boolean.valueOf(value), Boolean.valueOf(ovalue));
        this.disband = value;
    }

    /**
     * Requests that the <code>partyService</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPartyService (PartyMarshaller value)
    {
        PartyMarshaller ovalue = this.partyService;
        requestAttributeChange(
            PARTY_SERVICE, value, ovalue);
        this.partyService = value;
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
    public void setLocus (HostedLocus value)
    {
        HostedLocus ovalue = this.locus;
        requestAttributeChange(
            LOCUS, value, ovalue);
        this.locus = value;
    }
    // AUTO-GENERATED: METHODS END

    /**
     * May the specified player join this party? Note that you may join a party
     * you can't even see on the party board.
     *
     */
    public boolean mayJoin (PlayerName player)
    {
        return peeps.size() < PartyCodes.MAX_PARTY_SIZE &&
            (invitedIds.contains(player.getId()) || recruitment == PartyCodes.RECRUITMENT_OPEN);
    }

    @Override
    public PartyObject clone ()
    {
        try {
            PartyObject that = (PartyObject)super.clone();
            that.peeps = this.peeps.clone();
            that.partyService = null;
            return that;

        } catch (CloneNotSupportedException cnse) {
            throw new AssertionError(cnse);
        }
    }
}
