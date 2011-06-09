//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.client {
import flash.display.Stage;

import flashx.funk.ioc.BindingModule;

import com.threerings.util.Log;
import com.threerings.util.MessageManager;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.client.AetherDirector;
import com.threerings.orth.aether.client.FriendDirector;
import com.threerings.orth.chat.client.OrthChatDirector;
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
        bind(OrthModule).toInstance(this);

        // a handy stage reference
        bind(Stage).toInstance(stage);

        // our context and client
        bind(OrthContext).asSingleton();
        bind(AetherClient).asSingleton();

        // various singletons
        bind(MessageManager).asSingleton();
        bind(LocusDirector).asSingleton();
        bind(OrthController).asSingleton();
        bind(AetherDirector).asSingleton();
        bind(FriendDirector).asSingleton();
        bind(OrthChatDirector).asSingleton();
        bind(PartyDirector).asSingleton();
        bind(GuildDirector).asSingleton();

        // we have a simple implementation of LayeredContainer
        bind(LayeredContainer).to(SimpleLayeredContainer);

        // as is the placebox
        bind(OrthPlaceBox).asSingleton();

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
