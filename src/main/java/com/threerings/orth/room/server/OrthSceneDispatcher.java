//
// $Id$

package com.threerings.orth.room.server;

import javax.annotation.Generated;

import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;
import com.threerings.whirled.client.SceneService;

/**
 * Dispatches requests to the {@link OrthSceneProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from OrthSceneService.java.")
public class OrthSceneDispatcher extends InvocationDispatcher<OrthSceneMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public OrthSceneDispatcher (OrthSceneProvider provider)
    {
        this.provider = provider;
    }

    @Override
    public OrthSceneMarshaller createMarshaller ()
    {
        return new OrthSceneMarshaller();
    }

    @Override
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case OrthSceneMarshaller.MOVE_TO:
            ((OrthSceneProvider)provider).moveTo(
                source, ((Integer)args[0]).intValue(), ((Integer)args[1]).intValue(), ((Integer)args[2]).intValue(), (OrthLocation)args[3], (SceneService.SceneMoveListener)args[4]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
