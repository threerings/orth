//
// $Id: WorldService.java 18317 2009-10-08 23:12:28Z zell $

package com.threerings.orth.world.client;

import com.threerings.orth.world.data.OrthPlace;
import com.threerings.orth.world.data.PlaceKey;
import com.threerings.presents.client.InvocationService;

/**
 * Provides global services to the world client.
 */
public interface WorldService extends InvocationService
{
    public static interface PlaceResolutionListener extends InvocationListener
    {
        public void placeLocated (String host, int[] ports, OrthPlace place);
    }

    public void locatePlace (PlaceKey key, PlaceResolutionListener listener);
}
