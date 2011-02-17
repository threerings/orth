//
// $Id$
// Cabbage

package com.threerings.orth.world.client {

import flashx.funk.ioc.BindingModule;
import flashx.funk.ioc.ChainModule;
import flashx.funk.ioc.Module;
import flashx.funk.util.isAbstract;

import com.threerings.orth.client.OrthModule;

/**
 * Interfaces and abstract classes that must be bound in any implementing layer:
 *  - MuteDirector
 */
public class AbstractWorldModule extends BindingModule
{
    public function AbstractWorldModule ()
    {
        // bind the context
        bind(WorldContext).to(getWorldContextClass()).asSingleton();
    }
    
    final public function init (oMod :OrthModule) :Module
    {
        // create the two-pronged injection scope
        var cMod:ChainModule = new ChainModule(oMod,  this);
        bind(Module).toInstance(cMod);

        // and instantiate the context in that scope (and much of the world layer with it)
        var ctx :WorldContext = cMod.getInstance(WorldContext);

        cMod.inject(function () :void {
            doWorldBinds(ctx);
        });

        return cMod;
    }

    protected /* abstract */ function getWorldContextClass () :Class
    {
        return isAbstract();
    }

    protected function doWorldBinds (ctx :WorldContext) :void
    {
        // empty, but subclasses will want to implement
    }
}
}
