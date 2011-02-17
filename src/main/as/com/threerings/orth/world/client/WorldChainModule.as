//
// $Id$

package com.threerings.orth.world.client {

import flashx.funk.ioc.ChainModule;

import com.threerings.orth.client.OrthModule;
import com.threerings.orth.world.client.AbstractWorldModule;
import com.threerings.orth.world.client.WorldModule;

/**
 * Simply extend ChainModule and implement WorldModule.
 */
public class WorldChainModule extends ChainModule
    implements WorldModule
{
    public function WorldChainModule (oMod :OrthModule, wMod :AbstractWorldModule)
    {
        super(wMod, oMod);
    }
}
}
