//
// $Id: $

package com.threerings.orth.peer.data;

import javax.annotation.Generated;
import com.threerings.util.ActionScript;

import com.threerings.presents.dobj.DSet;
import com.threerings.presents.peer.data.NodeObject;

import com.threerings.crowd.peer.data.CrowdNodeObject;

import com.threerings.orth.party.data.MemberParty;
import com.threerings.orth.party.data.PartyInfo;
import com.threerings.orth.party.data.PartySummary;
import com.threerings.orth.party.data.PeerPartyMarshaller;
import com.threerings.orth.peer.data.HostedPlace;

/**
 * Maintains information on an Orth peer server.
 */
@ActionScript(omit=true)
public class OrthNodeObject extends NodeObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>hostedPlaces</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String HOSTED_PLACES = "hostedPlaces";

    /** The field name of the <code>hostedParties</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String HOSTED_PARTIES = "hostedParties";

    /** The field name of the <code>partyInfos</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PARTY_INFOS = "partyInfos";

    /** The field name of the <code>memberParties</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String MEMBER_PARTIES = "memberParties";

    /** The field name of the <code>peerPartyService</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PEER_PARTY_SERVICE = "peerPartyService";
    // AUTO-GENERATED: FIELDS END

    /** Contains info on all places hosted by this server. */
    public DSet<HostedPlace> hostedPlaces = DSet.newDSet();

    /** Contains the immutable summaries for all parties on this node. */
    public DSet<PartySummary> hostedParties = DSet.newDSet();

    /** Contains the mutable attributes of a party. */
    public DSet<PartyInfo> partyInfos = DSet.newDSet();

    /** Contains the current partyId of all members partying on this server. */
    public DSet<MemberParty> memberParties = DSet.newDSet();

    /** Handles party communication between peers. */
    public PeerPartyMarshaller peerPartyService;

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the specified entry be added to the
     * <code>hostedPlaces</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToHostedPlaces (HostedPlace elem)
    {
        requestEntryAdd(HOSTED_PLACES, hostedPlaces, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>hostedPlaces</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromHostedPlaces (Comparable<?> key)
    {
        requestEntryRemove(HOSTED_PLACES, hostedPlaces, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>hostedPlaces</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateHostedPlaces (HostedPlace elem)
    {
        requestEntryUpdate(HOSTED_PLACES, hostedPlaces, elem);
    }

    /**
     * Requests that the <code>hostedPlaces</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setHostedPlaces (DSet<HostedPlace> value)
    {
        requestAttributeChange(HOSTED_PLACES, value, this.hostedPlaces);
        DSet<HostedPlace> clone = (value == null) ? null : value.clone();
        this.hostedPlaces = clone;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>hostedParties</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToHostedParties (PartySummary elem)
    {
        requestEntryAdd(HOSTED_PARTIES, hostedParties, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>hostedParties</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromHostedParties (Comparable<?> key)
    {
        requestEntryRemove(HOSTED_PARTIES, hostedParties, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>hostedParties</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateHostedParties (PartySummary elem)
    {
        requestEntryUpdate(HOSTED_PARTIES, hostedParties, elem);
    }

    /**
     * Requests that the <code>hostedParties</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setHostedParties (DSet<PartySummary> value)
    {
        requestAttributeChange(HOSTED_PARTIES, value, this.hostedParties);
        DSet<PartySummary> clone = (value == null) ? null : value.clone();
        this.hostedParties = clone;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>partyInfos</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToPartyInfos (PartyInfo elem)
    {
        requestEntryAdd(PARTY_INFOS, partyInfos, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>partyInfos</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromPartyInfos (Comparable<?> key)
    {
        requestEntryRemove(PARTY_INFOS, partyInfos, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>partyInfos</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updatePartyInfos (PartyInfo elem)
    {
        requestEntryUpdate(PARTY_INFOS, partyInfos, elem);
    }

    /**
     * Requests that the <code>partyInfos</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPartyInfos (DSet<PartyInfo> value)
    {
        requestAttributeChange(PARTY_INFOS, value, this.partyInfos);
        DSet<PartyInfo> clone = (value == null) ? null : value.clone();
        this.partyInfos = clone;
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
     * Requests that the <code>peerPartyService</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPeerPartyService (PeerPartyMarshaller value)
    {
        PeerPartyMarshaller ovalue = this.peerPartyService;
        requestAttributeChange(
            PEER_PARTY_SERVICE, value, ovalue);
        this.peerPartyService = value;
    }
    // AUTO-GENERATED: METHODS END
}
