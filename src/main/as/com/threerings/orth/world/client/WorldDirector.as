//
// $Id: WorldDirector.as 18771 2009-11-24 22:03:46Z jamie $

package com.threerings.orth.world.client {

import com.threerings.io.TypedArray;

import com.threerings.util.Log;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.world.data.OrthPlace;

/**
 * Handles moving around in the virtual world.
 *
 */
public class WorldDirector extends BasicDirector
{
    public const log :Log = Log.getLog(this);

    public function WorldDirector (ctx :OrthContext)
    {
        super(ctx);

        _octx = ctx;
    }

    /**
     * Request a move.
     */
    public function moveTo (place :OrthPlace) :void
    {
        // ORTH TODO
//        _wsvc.moveTo(place, this);
    }

    // from WorldService.WorldMoveListener
    public function moveRequiresServerSwitch (host :String, ports :TypedArray /* of int */) :void
    {
        // ORTH TODO: to be implemented
    }

    // from WorldService.WorldMoveListener
    public function moveSucceeded (arg1 :int) :void
    {
        // ORTH TODO: to be implemented
    }

    // from BasicDirector
    override protected function clientObjectUpdated (client :Client) :void
    {
        super.clientObjectUpdated(client);
    }

    // from BasicDirector
    override protected function registerServices (client :Client) :void
    {
        client.addServiceGroup(OrthCodes.WORLD_GROUP);
    }

    // from BasicDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);

        _wsvc = (client.requireService(WorldService) as WorldService);
    }

    protected var _octx :OrthContext;
    protected var _wsvc :WorldService;
}
}
