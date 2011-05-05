//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.entity.client {

import flashx.funk.ioc.inject;

import com.threerings.orth.client.OrthController;

public class FurniBackend extends EntityBackend
{
    override protected function populateControlProperties (o :Object) :void
    {
        super.populateControlProperties(o);

        o["showPage_v1"] = showPage_v1;
    }

    protected function showPage_v1 (url :String) :Boolean
    {
        _orthCtrl.handleViewUrl(url);
        return true;
    }

    protected const _orthCtrl :OrthController = inject(OrthController);
}
}
