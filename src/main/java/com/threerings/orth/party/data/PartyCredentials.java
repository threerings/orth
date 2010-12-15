//
// $Id: PartyCredentials.java 14788 2009-02-12 18:18:00Z mdb $

package com.threerings.orth.party.data;

import com.threerings.orth.data.OrthCredentials;

/**
 * Used to authenticate a party session.
 */
public class PartyCredentials extends OrthCredentials
{
    /** The party that the authenticating user wishes to join. */
    public int partyId;

    @Override // from OrthCredentials
    protected void toString (StringBuilder buf)
    {
        super.toString(buf);
        buf.append(", partyId=").append(partyId);
    }
}
