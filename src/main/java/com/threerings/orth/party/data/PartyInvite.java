package com.threerings.orth.party.data;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.comms.data.SourcedComm;
import com.threerings.orth.data.ModuleStreamable;

public class PartyInvite extends ModuleStreamable
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
