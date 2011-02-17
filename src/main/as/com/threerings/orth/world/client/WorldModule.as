//
// $Id$

package com.threerings.orth.world.client {

import flashx.funk.ioc.Module;

/**
 * This interface exists purely to bind the {@link AbstractWorldModule} instance to
 * and for world classes to inject. We can't bind to Module because OrthModule does
 * already, and so ChainModule might find either binding.
 */
public interface WorldModule extends Module
{

}
}
