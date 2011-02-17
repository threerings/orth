//
// $Id$
// Cabbage

package com.threerings.orth.world.client {

import flashx.funk.ioc.BindingModule;
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

    final public function init (oMod :OrthModule) :WorldModule
    {
        // create the two-pronged injection scope
        _chainMod = new WorldChainModule(oMod,  this);
        bind(WorldModule).toInstance(_chainMod);

        // and instantiate the context in that scope (and much of the world layer with it)
        var ctx :WorldContext = _chainMod.getInstance(WorldContext);

        _chainMod.inject(function () :void {
            doWorldBinds(ctx);
        });

        return _chainMod;
    }

    protected /* abstract */ function getWorldContextClass () :Class
    {
        return isAbstract();
    }

    protected function doWorldBinds (ctx :WorldContext) :void
    {
        // empty, but subclasses will want to implement
    }

    protected var _chainMod :WorldModule;
}
}
