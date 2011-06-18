package com.threerings.orth.party.client;

import com.threerings.presents.client.InvocationReceiver;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.party.data.PartyObjectAddress;

public interface PartyRegistryReceiver
    extends InvocationReceiver
{
    void receiveInvitation(PlayerName inviter, PartyObjectAddress address);
}
