//
// $Id$

package com.threerings.orth.client {
import com.threerings.util.Log;
import flashx.funk.ioc.IModule;
import flashx.funk.ioc.AbstractModule;
import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;

import flash.display.Stage;

import mx.core.Application;

import com.threerings.util.MessageManager;

import com.threerings.orth.aether.client.AetherClient;

public class OrthModule extends AbstractModule
{
    public function OrthModule (app :Application)
    {
        _app = app; 
        bind(OrthModule).toInstance(this);
        bind(IModule).toInstance(this);

        // and the supplied application
        bind(Application).toInstance(_app);

        // set up a bunch of singletons
        bind(MessageManager).asSingleton();
        bind(OrthController).asSingleton();
        bind(OrthPlaceBox).asSingleton();
        bind(TopPanel).asSingleton();

        // a handy stage reference
        bind(Stage).toInstance(_app.stage);
    }

    protected var _app :Application;
    private static const log :Log = Log.getLog(OrthModule);
}
}
