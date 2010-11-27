//
// $Id$

package com.threerings.orth.party.data;

import javax.annotation.Generated;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.orth.data.MediaDesc;

public class PartyObject extends DObject
    implements /*SpeakObject,*/ Cloneable
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>id</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String ID = "id";

    /** The field name of the <code>name</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String NAME = "name";

    /** The field name of the <code>icon</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String ICON = "icon";

    /** The field name of the <code>peeps</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PEEPS = "peeps";

    /** The field name of the <code>leaderId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String LEADER_ID = "leaderId";

    /** The field name of the <code>sceneId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String SCENE_ID = "sceneId";

    /** The field name of the <code>gameId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String GAME_ID = "gameId";

    /** The field name of the <code>gameState</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String GAME_STATE = "gameState";

    /** The field name of the <code>gameOid</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String GAME_OID = "gameOid";

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
    // AUTO-GENERATED: FIELDS END

    /** A message sent to indicate a notification that should be dispatched to all partiers.
     * Format: [ Notification ]. */
    public static final String NOTIFICATION = "notification";

    /** This party's guid. */
    public int id;

    /** The name of this party. */
    public String name;

    /** The icon for this party. */
    public MediaDesc icon;

    /** The list of people in this party. */
    public DSet<PartyPeep> peeps = DSet.newDSet();

    /** The member ID of the current leader. */
    public int leaderId;

    /** The current location of the party. */
    public int sceneId;

    /** Customizable flavor text. */
    public String status;

    /** Helps interpret the status. */
    public byte statusType;

    /** This party's access control. @see PartyCodes */
    public byte recruitment;

    /** Do we disband when the leader leaves? */
    public boolean disband;

    /** The service for doing things on this party. */
    public PartyMarshaller partyService;

//    /** Speaking on this party object. */
//    public SpeakMarshaller speakService;

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>id</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setId (int value)
    {
        int ovalue = this.id;
        requestAttributeChange(
            ID, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.id = value;
    }

    /**
     * Requests that the <code>name</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setName (String value)
    {
        String ovalue = this.name;
        requestAttributeChange(
            NAME, value, ovalue);
        this.name = value;
    }

    /**
     * Requests that the <code>icon</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setIcon (MediaDesc value)
    {
        MediaDesc ovalue = this.icon;
        requestAttributeChange(
            ICON, value, ovalue);
        this.icon = value;
    }

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
     * Requests that the <code>sceneId</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setSceneId (int value)
    {
        int ovalue = this.sceneId;
        requestAttributeChange(
            SCENE_ID, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.sceneId = value;
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
    // AUTO-GENERATED: METHODS END

//    // from SpeakObject
//    public void applyToListeners (ListenerOp op)
//    {
//        for (PartyPeep peep : peeps) {
//            op.apply(peep.name);
//        }
//    }

    /**
     * May the specified player join this party? Note that you may join a party
     * you can't even see on the party board.
     *
     * @return the reason for failure, or null if joinage may proceed.
     */
    public String mayJoin (MemberName member, Rank groupRank, boolean hasLeaderInvite)
    {
        if (peeps.size() >= PartyCodes.MAX_PARTY_SIZE) {
            return PartyCodes.E_PARTY_FULL;
        }
        if (hasLeaderInvite) {
            return null;
        }

        switch (recruitment) {
        case PartyCodes.RECRUITMENT_OPEN:
            return null;

        case PartyCodes.RECRUITMENT_GROUP:
            if (groupRank.compareTo(Rank.NON_MEMBER) > 0) {
                return null;
            }
            return PartyCodes.E_PARTY_CLOSED;

        default:
        case PartyCodes.RECRUITMENT_CLOSED:
            return PartyCodes.E_PARTY_CLOSED;
        }
    }

    @Override
    public PartyObject clone ()
    {
        try {
            PartyObject that = (PartyObject)super.clone();
            that.peeps = this.peeps.clone();
            that.partyService = null;
//            that.speakService = null;
            return that;

        } catch (CloneNotSupportedException cnse) {
            throw new AssertionError(cnse);
        }
    }
}
