//
// $Id$

package com.threerings.orth.world.server;

import javax.annotation.Generated;

import com.threerings.orth.world.data.WorldMarshaller;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;

/**
 * Dispatches requests to the {@link WorldProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from WorldService.java.")
public class WorldDispatcher extends InvocationDispatcher<WorldMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public WorldDispatcher (WorldProvider provider)
    {
        this.provider = provider;
    }

    @Override
    public WorldMarshaller createMarshaller ()
    {
        return new WorldMarshaller();
    }

    @Override
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case WorldMarshaller.DITCH_FOLLOWER:
            ((WorldProvider)provider).ditchFollower(
                source, ((Integer)args[0]).intValue(), (InvocationService.InvocationListener)args[1]
            );
            return;

        case WorldMarshaller.FOLLOW_MEMBER:
            ((WorldProvider)provider).followMember(
                source, ((Integer)args[0]).intValue(), (InvocationService.InvocationListener)args[1]
            );
            return;

        case WorldMarshaller.INVITE_TO_FOLLOW:
            ((WorldProvider)provider).inviteToFollow(
                source, ((Integer)args[0]).intValue(), (InvocationService.InvocationListener)args[1]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
