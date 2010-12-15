//
// $Id$
package com.threerings.orth.player.server;

import javax.annotation.Generated;

import com.threerings.orth.player.data.PlayerMarshaller;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;

/**
 * Dispatches requests to the {@link PlayerProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PlayerService.java.")
public class PlayerDispatcher extends InvocationDispatcher<PlayerMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public PlayerDispatcher (PlayerProvider provider)
    {
        this.provider = provider;
    }

    @Override
    public PlayerMarshaller createMarshaller ()
    {
        return new PlayerMarshaller();
    }

    @Override
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
