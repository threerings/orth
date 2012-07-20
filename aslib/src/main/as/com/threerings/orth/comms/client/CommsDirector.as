//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.comms.client {

import flashx.funk.ioc.inject;

import org.osflash.signals.Signal;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.comms.data.CommDecoder;
import com.threerings.orth.comms.data.CommReceiver;

public class CommsDirector
   implements CommReceiver
{
    public const commReceived :Signal = new Signal(Object); // Dispatches the received comm

    public function CommsDirector ()
    {
        _aether.getInvocationDirector().registerReceiver(new CommDecoder(this));
    }

    public function receiveComm (comm :Object) :void
    {
        commReceived.dispatch(comm);
    }

    protected const _aether :AetherClient = inject(AetherClient);
}
}
