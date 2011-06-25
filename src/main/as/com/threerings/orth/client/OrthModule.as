//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.client {
import flash.display.Stage;

import flashx.funk.ioc.BindingModule;
import flashx.funk.ioc.Module;

import com.threerings.util.Log;
import com.threerings.util.MessageManager;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.client.AetherDirector;
import com.threerings.orth.aether.client.FriendDirector;
import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.comms.client.CommsDirector;
import com.threerings.orth.guild.client.GuildDirector;
import com.threerings.orth.locus.client.LocusDirector;
import com.threerings.orth.notify.client.NotificationDirector;
import com.threerings.orth.party.client.PartyDirector;
import com.threerings.orth.room.client.RoomModule;
import com.threerings.orth.room.data.RoomLocus;

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
        bind(Module).to(OrthModule);
        bind(OrthModule).toInstance(this);

        // a handy stage reference
        bind(Stage).toInstance(stage);

        // Singletons, A-Z
        bind(AetherClient).asSingleton();
        bind(AetherDirector).asSingleton();
        bind(CommsDirector).asSingleton();
        bind(FriendDirector).asSingleton();
        bind(GuildDirector).asSingleton();
        bind(LocusDirector).asSingleton();
        bind(MessageManager).asSingleton();
        bind(NotificationDirector).asSingleton();
        bind(OrthChatDirector).asSingleton();
        bind(OrthContext).asSingleton();
        bind(OrthController).asSingleton();
        bind(OrthPlaceBox).asSingleton();
        bind(PartyDirector).asSingleton();
        bind(TopPanel).asSingleton();

        // we have a simple implementation of LayeredContainer
        bind(LayeredContainer).to(SimpleLayeredContainer);

        // as is the placebox
    }

    public function init () :void
    {
        var ctx :OrthContext = getInstance(OrthContext);

        didInit();
        ctx.didInit();
    }

    protected function didInit () :void
    {
        // let the locus system know how to instantiate the room subsystem
        getInstance(LocusDirector).addBinding(RoomLocus, RoomModule);

        // instantiate directors and controllers
        getInstance(OrthChatDirector);
        getInstance(AetherDirector);
        getInstance(OrthController);
        getInstance(PartyDirector);
        getInstance(NotificationDirector);
        getInstance(GuildDirector);

    }

    private static const log :Log = Log.getLog(OrthModule);
}
}
