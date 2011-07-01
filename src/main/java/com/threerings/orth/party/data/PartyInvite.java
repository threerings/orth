package com.threerings.orth.party.data;

import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.comms.data.RequestComm;
import com.threerings.orth.data.OrthName;

public class PartyInvite extends BaseOneToOneComm
    implements RequestComm
{
    public PartyObjectAddress address;

    public PartyInvite (OrthName from, OrthName to, PartyObjectAddress addr)
    {
        super(from, to);
        address = addr;
    }
}
