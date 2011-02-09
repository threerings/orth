//
// $Id$

package com.threerings.orth.world.client {

import flashx.funk.ioc.AbstractModule;

/**
 * Interfaces and abstract classes that must be bound in any implementating layer:
 *  - WorldContext
 *  - MuteDirector
 */
public class WorldModule extends AbstractModule
{
    public function WorldModule ()
    {
        bind(WorldModule).toInstance(this);
    }
}
}