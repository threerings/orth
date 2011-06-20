package com.threerings.orth.party.data;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.comms.data.SourcedComm;

public class PartyInvite extends SimpleStreamableObject
    implements SourcedComm
{
    public PartyObjectAddress address;

    public PartyInvite (PlayerName playerName, PartyObjectAddress addr)
    {
        _source = playerName;
        address = addr;
    }

    @Override
    public PlayerName getSource ()
    {
        return _source;
    }

    protected PlayerName _source;
}
