//
// $Id$

package com.threerings.orth.client {
import flash.display.Stage;

import flashx.funk.ioc.AbstractModule;
import flashx.funk.ioc.IModule;

import mx.core.Application;

import com.threerings.util.Log;
import com.threerings.util.MessageManager;

import com.threerings.orth.aether.client.AetherClient;

/**
 * Interfaces and abstract classes that must be bound in any implementating layer:
 *  - OrthDeploymentConfig
 *  - OrthResourceFactory
 */
public class OrthModule extends AbstractModule
{
    public function OrthModule (app :Application)
    {
        // bind this module
        bind(OrthModule).toInstance(this);
        bind(IModule).toInstance(this);

        // and the supplied application
        bind(Application).toInstance(app);

        // a handy stage reference
        bind(Stage).toInstance(app.stage);

        // our context and client
        bind(OrthContext).asSingleton();
        bind(AetherClient).asSingleton();

        // some managers and controllers
        bind(MessageManager).asSingleton();
        bind(OrthController).asSingleton();

        // UI elements
        bind(ControlBar).asSingleton();
        bind(OrthPlaceBox).asSingleton();
        bind(TopPanel).asSingleton();
    }

    private static const log :Log = Log.getLog(OrthModule);
}
}
