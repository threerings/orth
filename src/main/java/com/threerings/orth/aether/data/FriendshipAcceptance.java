package com.threerings.orth.aether.data;

import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.data.PlayerName;

public class FriendshipAcceptance extends BaseOneToOneComm
{
    public FriendshipAcceptance (PlayerName from, PlayerName to)
    {
        super(from, to);
    }
}
