//
// $Id$

package com.threerings.orth.aether.client {

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.data.OrthCodes;

public class PlayerDirector extends BasicDirector
{
    public function PlayerDirector (ctx :PresentsContext)
    {
        super(ctx);
    }

    // from BasicDirector
    override protected function registerServices (client :Client) :void
    {
        client.addServiceGroup(OrthCodes.PLAYER_GROUP);
    }

    // from BasicDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);

        _psvc = (client.requireService(PlayerService) as PlayerService);
    }

    protected var _psvc :PlayerService;
}
}
