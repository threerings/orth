//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import javax.annotation.Generated;

import com.threerings.presents.data.ClientObject;

import com.threerings.orth.data.PlayerName;

/**
 * Contains information on a party player logged into the server.
 */
public class PartierObject extends ClientObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>playerName</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PLAYER_NAME = "playerName";

    /** The field name of the <code>partyId</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PARTY_ID = "partyId";
    // AUTO-GENERATED: FIELDS END

    /** The name and id information for this user. */
    public PlayerName playerName;

    /** The party to which this partier is party. */
    public int partyId;

    /**
     * Returns this player's unique id.
     */
    public int getPlayerId ()
    {
        return playerName.getId();
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
