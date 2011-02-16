//
// $Id$
// Cabbage

package com.threerings.orth.world.client {
import flashx.funk.ioc.AbstractModule;
import flashx.funk.ioc.ChainModule;
import flashx.funk.ioc.IModule;

import com.threerings.orth.client.OrthModule;

/**
 * Interfaces and abstract classes that must be bound in any implementing layer:
 *  - MuteDirector
 */
public class AbstractWorldModule extends AbstractModule
{
    final public function init (oMod :OrthModule) :IModule
    {
        // bind the context
        bind(WorldContext).to(getWorldContextClass()).asSingleton();

        // create the two-pronged injection scope
        var cMod:ChainModule = new ChainModule(oMod,  this);
        bind(IModule).toInstance(cMod);

        // and instantiate the context in that scope (and much of the world layer with it)
        var ctx :WorldContext = cMod.getInstance(WorldContext);

        doWorldBinds(ctx);

        return cMod;
    }

    protected /* abstract */ function getWorldContextClass () :Class
    {
        throw new Error("must be implemented");
    }

    protected function doWorldBinds (ctx :WorldContext) :void
    {
        // empty, but subclasses will want to implement
    }
}
}
