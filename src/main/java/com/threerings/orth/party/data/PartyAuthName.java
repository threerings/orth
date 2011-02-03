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
    public static PartyAuthName makeKey (int playerId)
    {
        return new PartyAuthName("", playerId);
    }

    /** Creates a name for the player with the supplied account name and player id. */
    public PartyAuthName (String accountName, int playerId)
    {
        super(accountName, playerId);
    }

    /** Used for unserializing. */
    public PartyAuthName ()
    {
    }
}
