//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import javax.annotation.Generated;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.locus.data.HostedLocus;

public class PartyObject extends DObject
    implements Cloneable
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>peeps</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PEEPS = "peeps";

    /** The field name of the <code>leaderId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String LEADER_ID = "leaderId";

    /** The field name of the <code>policy</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String POLICY = "policy";

    /** The field name of the <code>disband</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String DISBAND = "disband";

    /** The field name of the <code>partyService</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PARTY_SERVICE = "partyService";

    /** The field name of the <code>partyChatService</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PARTY_CHAT_SERVICE = "partyChatService";

    /** The field name of the <code>locus</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String LOCUS = "locus";
    // AUTO-GENERATED: FIELDS END

    /** The list of people in this party. */
    public DSet<PartyPeep> peeps = DSet.newDSet();

    /** The player ID of the current leader. */
    public int leaderId;

    /** This party's access control. @see PartyCodes */
    public PartyPolicy policy;

    /** Do we disband when the leader leaves? */
    public boolean disband = true;

    /** The service for doing things on this party. */
    public PartyMarshaller partyService;

    /** The chat service for this party. */
    public SpeakMarshaller partyChatService;

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
     * Requests that the <code>policy</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPolicy (PartyPolicy value)
    {
        PartyPolicy ovalue = this.policy;
        requestAttributeChange(
            POLICY, value, ovalue);
        this.policy = value;
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
     * Requests that the <code>partyChatService</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPartyChatService (SpeakMarshaller value)
    {
        SpeakMarshaller ovalue = this.partyChatService;
        requestAttributeChange(
            PARTY_CHAT_SERVICE, value, ovalue);
        this.partyChatService = value;
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
