//
// $Id$

package com.threerings.orth.locus.client {

import flashx.funk.ioc.BindingModule;
import flashx.funk.util.isAbstract;

import com.threerings.orth.client.OrthModule;

public class AbstractLocusModule extends BindingModule
{
    public function AbstractLocusModule ()
    {
        // the locus controller
        bind(LocusController).asSingleton();
    }

    final public function init (oMod :OrthModule) :LocusContext
    {
        // create the two-pronged injection scope
        _chainMod = new LocusChainModule(oMod,  this);

        var ctx :LocusContext;

        // and instantiate the context in that scope (and much of the locus layer with it)
        _chainMod.inject(function () :void {
            ctx = createContext();
            ctx.getLocusClient().initWithModule(_chainMod);
            doLocusBinds(ctx);
        });

        // force the instantiation of LocusController early
        _chainMod.getInstance(LocusController);

        return ctx;
    }

    protected function createContext () :LocusContext
    {
        return isAbstract();
    }

    protected function doLocusBinds (ctx :LocusContext) :void
    {
        // empty, but subclasses will want to implement
    }

    protected var _chainMod :LocusModule;
}
}
