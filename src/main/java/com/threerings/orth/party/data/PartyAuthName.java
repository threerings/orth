//
// $Id: PartyAuthName.java 19629 2010-11-24 16:40:04Z zell $

package com.threerings.orth.party.data;

import com.threerings.orth.data.AuthName;

/**
 * Identifies the auth-username of a party authentication request.
 */
public class PartyAuthName extends AuthName
{
    /**
     * Creates an instance that can be used as a DSet key.
     */
    public static PartyAuthName makeKey (int memberId)
    {
        return new PartyAuthName("", memberId);
    }

    /** Creates a name for the member with the supplied account name and member id. */
    public PartyAuthName (String accountName, int memberId)
    {
        super(accountName, memberId);
    }

    /** Used for unserializing. */
    public PartyAuthName ()
    {
    }
}
