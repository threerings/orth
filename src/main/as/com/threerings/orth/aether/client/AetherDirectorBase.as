//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client {
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.presents.client.ClientEvent;

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

    override public function clientDidLogoff (event :ClientEvent) :void
    {
        super.clientDidLogoff(event);

        shutdown();
    }

    public function isShutdown () :Boolean
    {
        return _module == null;
    }

    /**
     * Called when the Aether client disconnects; clear out any resources
     */
    protected function shutdown () :void
    {
        _module = null;
    }

    protected var _module :Module = inject(OrthModule);
}
}
