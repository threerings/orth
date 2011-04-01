package com.threerings.orth.aether.data;

import com.threerings.orth.data.AuthName;

public class AetherAuthName extends AuthName
{
    /**
     * Creates an instance that can be used as a DSet key.
     */
    public static AetherAuthName makeKey (int playerId)
    {
        return new AetherAuthName("", playerId);
    }

    /** Creates a name for the player with the supplied account name and player id. */
    public AetherAuthName (String accountName, int playerId)
    {
        super(accountName, playerId);
    }
}
