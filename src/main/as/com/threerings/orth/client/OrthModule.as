//
// $Id$

package com.threerings.orth.client {
import flash.display.Stage;

import flashx.funk.ioc.BindingModule;

import com.threerings.util.Log;
import com.threerings.util.MessageManager;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.client.PlayerDirector;
import com.threerings.orth.chat.client.ComicOverlay;
import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.party.client.PartyDirector;
import com.threerings.orth.room.client.editor.DoorTargetEditController;
import com.threerings.orth.room.client.editor.RoomEditorController;

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

        // the chat overlay is a singleton
        bind(ComicOverlay).asSingleton();

        // editor bits
        bind(RoomEditorController).asSingleton();
        bind(DoorTargetEditController).asSingleton();

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
        // instantiate directors and controllers
        getInstance(OrthChatDirector);
        getInstance(PlayerDirector);
        getInstance(OrthController);
        getInstance(PartyDirector);
    }

    private static const log :Log = Log.getLog(OrthModule);
}
}
