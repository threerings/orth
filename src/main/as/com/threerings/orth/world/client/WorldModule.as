//
// $Id$

package com.threerings.orth.world.client {
import flashx.funk.ioc.ChainModule;

import com.threerings.orth.client.OrthModule;

/**
 * Interfaces and abstract classes that must be bound in any implementating layer:
 *  - MuteDirector
 */
public class WorldModule extends ChainModule
{
    public function WorldModule (oMod :OrthModule, ctxClass :Class)
    {
        super(oMod);

        // bind the context
        bind(WorldContext).to(ctxClass).asSingleton();

        bind(WorldModule).toInstance(this);
    }
}
}
