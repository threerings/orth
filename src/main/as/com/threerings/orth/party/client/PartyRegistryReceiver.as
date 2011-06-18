//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client {

import com.threerings.presents.client.InvocationReceiver;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.party.data.PartyObjectAddress;

public interface PartyRegistryReceiver extends InvocationReceiver
{
    // from Java interface PartyRegistryReceiver
    function receiveInvitation (arg1 :PlayerName, arg2 :PartyObjectAddress) :void;
}
}
