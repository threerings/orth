//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client {

import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.client.OrthModule;
import com.threerings.orth.util.OrthDirector;

/**
 * An OrthDirector that specifically operates in the Aether.
 */
public class AetherDirectorBase extends OrthDirector
{
    public function AetherDirectorBase ()
    {
        super(inject(AetherClient));
    }

    public function get aetherObj () :AetherClientObject
    {
        return AetherClient(_client).aetherObject;
    }

    protected var _module :Module = inject(OrthModule);
}
}
