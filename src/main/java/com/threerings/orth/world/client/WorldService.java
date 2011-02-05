//
// $Id: WorldService.java 18317 2009-10-08 23:12:28Z zell $

package com.threerings.orth.world.client;

import com.threerings.io.Streamable;
import com.threerings.presents.client.InvocationService;

import com.threerings.orth.world.data.PlaceKey;
import com.threerings.orth.world.data.OrthPlace;

/**
 * Provides global services to the world client.
 */
public interface WorldService extends InvocationService
{
    public static interface PlaceResolutionListener extends InvocationListener
    {
        public void placeLocated (OrthPlace place);
        public void resolutionFailed (PlaceKey key, String cause);
    }

    public void locatePlace (PlaceKey key, PlaceResolutionListener listener);
}
