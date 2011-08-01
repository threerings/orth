//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client {

import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.chat.client.MuteDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.client.persist.SceneRepository;
import com.threerings.whirled.spot.client.SpotSceneDirector;

import com.threerings.util.MessageManager;

import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.locus.client.AbstractLocusModule;
import com.threerings.orth.locus.client.LocusContext;

public class RoomModule extends AbstractLocusModule
{
    public function RoomModule ()
    {
        // set up simple bindings in the constructor
        bind(RoomClient).asSingleton();

        // mark our fake chat director as a singleton
        bind(FakeChatDirector).asSingleton();

        // the SceneDirector needs a binding for SceneRepository
        bind(SceneRepository).to(NullSceneRepository).asSingleton();
    }

    override protected function doLocusBinds (ctx :LocusContext) :void
    {
        var rCtx :RoomContext = RoomContext(ctx);
        bind(RoomContext).toInstance(ctx);
        bind(RoomModule).toInstance(_chainMod);

        // instantiate it, so that it may register its services early
        _chainMod.getInstance(FakeChatDirector);

        // instantiate and bind the directors that need explicit instantiation
        bind(MuteDirector).toInstance(new MuteDirector(rCtx));

        var locDir :LocationDirector = new OrthLocationDirector(rCtx);
        bind(LocationDirector).toInstance(locDir);

        bind(SceneDirector).to(OrthSceneDirector);
        var scDir :SceneDirector = _chainMod.inject(newSceneDirector);
        bind(OrthSceneDirector).toInstance(scDir);

        bind(SpotSceneDirector).toInstance(new SpotSceneDirector(rCtx, locDir, scDir));

        // these rely on LocationDirector, so let's bind them after
        bind(MediaDirector).toInstance(new MediaDirector(rCtx, locDir));
        bind(OccupantDirector).toInstance(new OccupantDirector(rCtx));

        bind(ChatDirector).toInstance(new ChatDirector(
            rCtx, _chainMod.getInstance(MessageManager), OrthCodes.CHAT_MSGS));
    }

    /**
     * Create a new OrthSceneDirector; for subclasses to override.
     * TODO: Figure out how to do this with injection bindings in spite of the crazy race
     * conditions that made this approach necessary(?) in the first place.
     */
    protected function newSceneDirector () :OrthSceneDirector
    {
        return new OrthSceneDirector();
    }

    override protected function createContext () :LocusContext
    {
        return new RoomContext();
    }
}
}
