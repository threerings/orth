//
// $Id$

package com.threerings.orth.room.client {

import flashx.funk.ioc.AbstractModule;

import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.whirled.spot.client.SpotSceneDirector;

// ORTH TODO: Should subclass WorldModule
public class RoomModule extends AbstractModule
{
    public function RoomModule (ctx :RoomContext)
    {
        // bind the directors that need explicit instantiation
        bind(LocationDirector).toInstance(ctx.getLocationDirector());
        bind(OccupantDirector).toInstance(ctx.getOccupantDirector());
        bind(SpotSceneDirector).toInstance(ctx.getSpotSceneDirector());
    }
}
}
