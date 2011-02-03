//
// $Id$
package com.threerings.orth.world.server;

import javax.annotation.Generated;

import com.threerings.orth.world.client.WorldService;
import com.threerings.orth.world.data.OrthPlace;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link WorldService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from WorldService.java.")
public interface WorldProvider extends InvocationProvider
{
    /**
     * Handles a {@link WorldService#moveTo} request.
     */
    void moveTo (ClientObject caller, OrthPlace arg1, WorldService.WorldMoveListener arg2)
        throws InvocationException;
}
