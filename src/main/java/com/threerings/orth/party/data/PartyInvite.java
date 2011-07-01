package com.threerings.orth.party.data;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.comms.data.RequestComm;

public class PartyInvite extends BaseOneToOneComm
    implements RequestComm
{
    public PartyObjectAddress address;

    public PartyInvite (PlayerName from, PlayerName to, PartyObjectAddress addr)
    {
        super(from, to);
        address = addr;
    }
}
