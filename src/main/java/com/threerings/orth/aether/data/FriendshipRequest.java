package com.threerings.orth.aether.data;

import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.comms.data.RequestComm;
import com.threerings.orth.data.OrthName;

public class FriendshipRequest extends BaseOneToOneComm
    implements RequestComm
{
    public FriendshipRequest (OrthName from, OrthName to)
    {
        super(from, to);
    }
}
