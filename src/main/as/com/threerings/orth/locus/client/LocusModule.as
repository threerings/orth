//
// $Id$

package com.threerings.orth.locus.client {

import flashx.funk.ioc.Module;

/**
 * This interface exists purely to bind the {@link AbstractLocusModule} instance to
 * and for locus classes to inject. We can't bind to Module because OrthModule does
 * already, and so ChainModule might find either binding.
 */
public interface LocusModule extends Module
{

}
}
