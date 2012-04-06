//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client {
import com.threerings.presents.client.Client;

import com.threerings.orth.aether.data.IgnoreMarshaller;
import com.threerings.orth.client.Listeners;
import com.threerings.orth.data.PlayerName;

public class IgnoreDirector extends AetherDirectorBase
{
    IgnoreMarshaller;

    public function ignorePlayer (ignoree :PlayerName, doIgnore :Boolean) :void
    {
        _isvc.ignorePlayer(ignoree.id, doIgnore, Listeners.listener());
    }

    override protected function fetchServices (client :Client) :void
    {
        _isvc = client.requireService(IgnoreService);
    }

    protected var _isvc :IgnoreService;
}
}
