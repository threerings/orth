//
// $Id$

package com.threerings.orth.room.client {

import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.spot.client.SpotSceneDirector;

import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.world.client.WorldModule;

public class RoomModule extends WorldModule
{
    public function RoomModule ()
    {
        super();

        // bind the context
        bind(WorldContext).to(RoomContext).asSingleton();

        // grab an instance
        var ctx :RoomContext = getInstance(WorldContext);

        // bind the directors that need explicit instantiation
        bind(LocationDirector).toInstance(ctx.getLocationDirector());
        bind(OccupantDirector).toInstance(ctx.getOccupantDirector());
        bind(SceneDirector).toInstance(ctx.getSceneDirector());
        bind(SpotSceneDirector).toInstance(ctx.getSpotSceneDirector());

        // later we will most likely need to bind WorldClient to a RoomClient singleton here
    }
}
}
