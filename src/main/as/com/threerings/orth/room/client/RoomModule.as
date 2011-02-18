//
// $Id$

package com.threerings.orth.room.client {

import com.threerings.crowd.chat.client.MuteDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.client.persist.SceneRepository;
import com.threerings.whirled.spot.client.SpotSceneDirector;

import com.threerings.orth.world.client.AbstractWorldModule;
import com.threerings.orth.world.client.WorldClient;
import com.threerings.orth.world.client.WorldContext;

public class RoomModule extends AbstractWorldModule
{
    public function RoomModule ()
    {
        // set up simple bindings in the constructor
        bind(WorldClient).to(RoomClient).asSingleton();
    }

    override protected function doWorldBinds (ctx :WorldContext) :void
    {
        var rCtx :RoomContext = RoomContext(ctx);

        // instantiate and bind the directors that need explicit instantiation
        bind(MuteDirector).toInstance(new MuteDirector(rCtx));

        // the SceneDirector needs a binding for SceneRepository
        bind(SceneRepository).to(NullSceneRepository).asSingleton();

        var locDir :LocationDirector = new OrthLocationDirector(rCtx);
        bind(LocationDirector).toInstance(locDir);

        var scDir :SceneDirector = _chainMod.getInstance(OrthSceneDirector);
        bind(SceneDirector).to(OrthSceneDirector).asSingleton();

        bind(SpotSceneDirector).toInstance(new SpotSceneDirector(rCtx, locDir, scDir));

        // these rely on LocationDirector, so let's bind them after
        bind(MediaDirector).toInstance(new MediaDirector(rCtx, locDir));
        bind(OccupantDirector).toInstance(new OccupantDirector(rCtx));
    }

    override protected function getWorldContextClass () :Class
    {
        return RoomContext;
    }
}
}
