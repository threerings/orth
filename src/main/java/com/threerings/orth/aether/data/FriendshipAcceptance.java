package com.threerings.orth.aether.data;

import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.data.OrthName;

public class FriendshipAcceptance extends BaseOneToOneComm
{
    public FriendshipAcceptance (OrthName from, OrthName to)
    {
        super(from, to);
    }
}
