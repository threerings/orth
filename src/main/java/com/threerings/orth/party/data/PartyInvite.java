//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.comms.data.BaseOneToOneComm;
import com.threerings.orth.comms.data.RequestComm;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.nodelet.data.HostedNodelet;

public class PartyInvite extends BaseOneToOneComm
    implements RequestComm
{
    public HostedNodelet hosted;

    public PartyInvite (PlayerName from, PlayerName to, HostedNodelet hosted)
    {
        super(from, to);

        this.hosted = hosted;
    }

    public void aetherInfusion (AetherClientObject plobj)
    {
        // nothing; override
    }
}
