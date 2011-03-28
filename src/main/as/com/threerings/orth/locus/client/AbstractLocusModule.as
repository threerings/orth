//
// $Id$
// Cabbage

package com.threerings.orth.locus.client {

import flashx.funk.ioc.BindingModule;
import flashx.funk.util.isAbstract;

import com.threerings.orth.client.OrthModule;

public class AbstractLocusModule extends BindingModule
{
    public function AbstractLocusModule ()
    {
        // bind the context
        bind(LocusContext).to(getLocusContextClass()).asSingleton();

        // the locus controller
        bind(LocusController).asSingleton();
    }

    final public function init (oMod :OrthModule) :LocusModule
    {
        // create the two-pronged injection scope
        _chainMod = new LocusChainModule(oMod,  this);
        bind(LocusModule).toInstance(_chainMod);

        // and instantiate the context in that scope (and much of the locus layer with it)
        var ctx :LocusContext = _chainMod.getInstance(LocusContext);

        _chainMod.inject(function () :void {
            doLocusBinds(ctx);
        });

        // force the instantiation of LocusController early
        _chainMod.getInstance(LocusController);

        return _chainMod;
    }

    protected /* abstract */ function getLocusContextClass () :Class
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
