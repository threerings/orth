//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client {
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ConfirmAdapter;

import com.threerings.orth.client.Listeners;

/**
 * Handles player-oriented requests.
 */
public class AetherDirector extends AetherDirectorBase
{
    public function acceptGuildInvite (senderId :int, guildId :int) :void
    {
        _psvc.acceptGuildInvite(senderId, guildId, Listeners.listener());
    }

    public function createGuild (name :String, confirmed :Function, failed :Function) :void
    {
        _psvc.createGuild(name, new ConfirmAdapter(confirmed, failed));
    }

    override protected function fetchServices (client :Client) :void
    {
        _psvc = client.requireService(AetherService);
    }

    protected var _psvc :AetherService;
}
}
