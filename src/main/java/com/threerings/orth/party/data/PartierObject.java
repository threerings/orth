//
// $Id: PartierObject.java 19625 2010-11-24 15:47:54Z zell $

package com.threerings.orth.party.data;

import javax.annotation.Generated;

import com.threerings.util.ActionScript;
import com.threerings.util.Name;

import com.threerings.crowd.data.BodyObject;

import com.threerings.orth.data.OrthName;

/**
 * Contains information on a party member logged into the server.
 */
@ActionScript(omit=true)
public class PartierObject extends BodyObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>memberName</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String MEMBER_NAME = "memberName";

    /** The field name of the <code>partyId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PARTY_ID = "partyId";
    // AUTO-GENERATED: FIELDS END

    /** The name and id information for this user. */
    public OrthName memberName;

    /** The party to which this partier is party. */
    public int partyId;

    /**
     * Returns this member's unique id.
     */
    public int getMemberId ()
    {
        return memberName.getId();
    }

    @Override // from BodyObject
    public Name getVisibleName ()
    {
        return memberName;
    }

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>memberName</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setMemberName (OrthName value)
    {
        OrthName ovalue = this.memberName;
        requestAttributeChange(
            MEMBER_NAME, value, ovalue);
        this.memberName = value;
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
}
