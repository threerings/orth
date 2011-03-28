//
// $Id$

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
import com.threerings.orth.room.client.FakeChatDirector;
import com.threerings.orth.locus.client.AbstractLocusModule;
import com.threerings.orth.locus.client.LocusClient;
import com.threerings.orth.locus.client.LocusContext;

public class RoomModule extends AbstractLocusModule
{
    public function RoomModule ()
    {
        // set up simple bindings in the constructor
        bind(LocusClient).to(RoomClient).asSingleton();
    }

    override protected function doLocusBinds (ctx :LocusContext) :void
    {
        var rCtx :RoomContext = RoomContext(ctx);

        // mark our fake chat director as a singleton
        bind(FakeChatDirector).asSingleton();
        // instantiate it, so that it may register its services early
        _chainMod.getInstance(FakeChatDirector);

        // instantiate and bind the directors that need explicit instantiation
        bind(MuteDirector).toInstance(new MuteDirector(rCtx));

        // the SceneDirector needs a binding for SceneRepository
        bind(SceneRepository).to(NullSceneRepository).asSingleton();

        var locDir :LocationDirector = new OrthLocationDirector(rCtx);
        bind(LocationDirector).toInstance(locDir);

        var scDir :SceneDirector = _chainMod.getInstance(OrthSceneDirector);
        bind(OrthSceneDirector).toInstance(scDir);
        bind(SceneDirector).toInstance(scDir);

        bind(SpotSceneDirector).toInstance(new SpotSceneDirector(rCtx, locDir, scDir));

        // these rely on LocationDirector, so let's bind them after
        bind(MediaDirector).toInstance(new MediaDirector(rCtx, locDir));
        bind(OccupantDirector).toInstance(new OccupantDirector(rCtx));

        bind(ChatDirector).toInstance(new ChatDirector(
            rCtx, _chainMod.getInstance(MessageManager), OrthCodes.CHAT_MSGS));
    }

    override protected function getLocusContextClass () :Class
    {
        return RoomContext;
    }
}
}
