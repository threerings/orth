//
// $Id$

package com.threerings.orth.client {

import flash.display.Stage;

import mx.core.Application;

import org.swiftsuspenders.Injector;

import com.threerings.util.MessageManager;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.client.AetherClient;

import com.threerings.orth.world.client.WorldClient;
import com.threerings.orth.world.client.WorldContext;

public class OrthModule
{
    public function configure (app :Application, injector :Injector) :void
    {
        // map the injector itself
        injector.mapValue(Injector, injector);

         // and the supplied application
        injector.mapValue(Application, app);

         // set up a bunch of singletons
        injector.mapSingleton(MessageManager);
        injector.mapSingleton(OrthContext);
        injector.mapSingleton(OrthController);
        injector.mapSingleton(OrthPlaceBox);
        injector.mapSingleton(TopPanel);

         // bind to our trivial deployment config
        var config :OrthDeploymentConfig = new TrivialDeploymentConfig();
        injector.mapValue(OrthDeploymentConfig, config);

        // a handy stage reference
        injector.mapValue(Stage, app.stage);
        // client width and height, defaults to app dimensions
        injector.mapValue(Number, app.stage.stageWidth, "clientWidth");
        injector.mapValue(Number, app.stage.stageHeight, "clientHeight");

        // client configuration
        injector.mapValue(String, "TODO", "aetherHostname");
        injector.mapValue(Array, "TODO", "aetherPorts");
        injector.mapSingleton(AetherClient);

         // to begin with, we have no WorldContext
        injector.mapValue(WorldContext, null);
    }
}            
}

import com.threerings.orth.client.OrthDeploymentConfig;

class TrivialDeploymentConfig implements OrthDeploymentConfig
{
    public function getVersion () :String
    {
        return "DEV";
    }

    public function isDevelopment () :Boolean
    {
        return true;
    }
}
