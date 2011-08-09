//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.client {
import com.threerings.orth.client.Listeners;

import flashx.funk.ioc.inject;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;

import com.threerings.orth.client.OrthContext;

/**
 * Handles player-oriented requests.
 */
public class AetherDirector
{
    public function AetherDirector ()
    {
        const client :Client = inject(AetherClient);
        client.addEventListener(ClientEvent.CLIENT_DID_LOGON, function (..._) :void {
            _psvc = client.requireService(AetherService);
        });
    }

    public function acceptGuildInvite (senderId :int, guildId :int) :void
    {
        _psvc.acceptGuildInvite(senderId, guildId, Listeners.listener());
    }

    public function createGuild (name :String) :void
    {
        _psvc.createGuild(name, Listeners.listener());
    }

    protected var _psvc :AetherService;
    protected const _octx :OrthContext = inject(OrthContext);
}
}
