//
// $Id: WorldService.java 18317 2009-10-08 23:12:28Z zell $

package com.threerings.orth.world.client;

import com.threerings.orth.world.data.OrthPlace;
import com.threerings.presents.client.InvocationService;

/**
 * Provides global services to the world client.
 */
public interface WorldService extends InvocationService
{
    /**
     * Used to communicate the response to a {@link WorldService#moveTo} request.
     */
    public static interface WorldMoveListener extends InvocationListener
    {
        /**
         * Indicates that a move succeeded.
         */
        public void moveSucceeded (int placeId);

        /**
         * Indicates that the client must switch to the specified server and reissue its move
         * request in order to relocate to its desired scene.
         */
        public void moveRequiresServerSwitch (String hostname, int[] ports);
    }
    

    /** Request that this client move to some new {@link OrthPlace}. */
    public void moveTo (OrthPlace place, WorldMoveListener listener);
}
