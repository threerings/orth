//
// $Id$

package com.threerings.orth.room.client {

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
        bind(WorldClient).to(RoomClient);
    }

    override protected function doWorldBinds (ctx :WorldContext) :void
    {
        var rCtx :RoomContext = RoomContext(ctx);

        // instantiate and bind the directors that need explicit instantiation
        var locDir :LocationDirector = new LocationDirector(rCtx);
        bind(LocationDirector).toInstance(locDir);

        var occDir :OccupantDirector = new OccupantDirector(rCtx);
        bind(OccupantDirector).toInstance(occDir);

        // the SceneDirector needs a binding for SceneRepository
        bind(SceneRepository).to(NullSceneRepository).asSingleton();

        var scDir :SceneDirector = new OrthSceneDirector();
        bind(SceneDirector).toInstance(scDir);

        bind(SpotSceneDirector).toInstance(new SpotSceneDirector(rCtx, locDir, scDir));
    }

    override protected function getWorldContextClass () :Class
    {
        return RoomContext;
    }
}
}
