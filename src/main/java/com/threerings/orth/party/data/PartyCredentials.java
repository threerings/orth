//
// $Id$

package com.threerings.orth.party.data;

import com.threerings.orth.data.TokenCredentials;

/**
 * Used to authenticate a party session.
 */
public class PartyCredentials extends TokenCredentials
{
    /** The party that the authenticating user wishes to join. */
    public int partyId;

    @Override // from TokenCredentials
    protected void toString (StringBuilder buf)
    {
        super.toString(buf);
        buf.append(", partyId=").append(partyId);
    }
}
