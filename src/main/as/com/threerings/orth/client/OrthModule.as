//
// $Id$

package com.threerings.orth.client {
import flash.display.Stage;

import flashx.funk.ioc.BindingModule;
import flashx.funk.ioc.Module;

import com.threerings.util.Log;
import com.threerings.util.MessageManager;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.client.PlayerDirector;
import com.threerings.orth.chat.client.ComicOverlay;
import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.party.client.PartyDirector;

/**
 * Interfaces and abstract classes that must be bound in any implementating layer:
 *  - OrthDeploymentConfig
 *  - OrthResourceFactory
 */
public class OrthModule extends BindingModule
{
    public function OrthModule (stage :Stage)
    {
        // bind this module
        bind(OrthModule).toInstance(this);
        bind(Module).toInstance(this);

        // a handy stage reference
        bind(Stage).toInstance(stage);

        // our context and client
        bind(OrthContext).asSingleton();
        bind(AetherClient).asSingleton();

        // some managers and controllers
        bind(MessageManager).asSingleton();
        bind(OrthController).asSingleton();
        bind(PlayerDirector).asSingleton();
        bind(OrthChatDirector).asSingleton();
        bind(PartyDirector).asSingleton();

        // UI elements
        bind(ControlBar).asSingleton();

        // narya bits
        bind(MessageManager).asSingleton();
    }

    public function init () :void
    {
        var ctx :OrthContext = getInstance(OrthContext);

        didInit();
        ctx.didInit();
    }

    protected function didInit () :void
    {
        // we instantiate these in explicit order so as to avoid a cyclic dependancy
        var placeBox :OrthPlaceBox = getInstance(OrthPlaceBox);
        bind(OrthPlaceBox).toInstance(placeBox);

        // the ComicOverlay is configured with the OrthPlaceBox and injects OrthContext
        var comicOverlay :ComicOverlay = getInstance(ComicOverlay);
        comicOverlay.initComicOverlay(placeBox);
        bind(ComicOverlay).toInstance(comicOverlay);

        // and TopPanel injects ComicOverlay!
        var topPanel :TopPanel = getInstance(TopPanel);
        bind(TopPanel).toInstance(topPanel);

        // instantiate directors and controllers
        getInstance(PlayerDirector);
        getInstance(OrthChatDirector);
        getInstance(OrthController);
        getInstance(PartyDirector);
    }

    private static const log :Log = Log.getLog(OrthModule);
}
}
