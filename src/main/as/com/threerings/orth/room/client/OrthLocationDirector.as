//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.client
{
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.data.PlaceConfig;
import com.threerings.crowd.util.CrowdContext;

public class OrthLocationDirector extends LocationDirector
{
    public function OrthLocationDirector (ctx :CrowdContext)
    {
        super(ctx);
    }

    override public function didMoveTo (placeId:int, config:PlaceConfig):void
    {
        var up :Function = super.didMoveTo;

        // we want the call to super.didMoveTo() to occur within an injection scope
        _module.inject(function () :void {
            up(placeId, config);
        });
    }

    protected const _module :Module = inject(Module);
}
}
