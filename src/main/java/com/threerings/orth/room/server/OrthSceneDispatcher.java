//
// $Id$

package com.threerings.orth.room.server;

import javax.annotation.Generated;

import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;
import com.threerings.whirled.spot.data.Location;

/**
 * Dispatches requests to the {@link OrthSceneProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from OrthRoomService.java.")
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
        case OrthSceneMarshaller.CHANGE_LOCATION:
            ((OrthSceneProvider)provider).changeLocation(
                source, (EntityIdent)args[0], (Location)args[1]
            );
            return;

        case OrthSceneMarshaller.REQUEST_CONTROL:
            ((OrthSceneProvider)provider).requestControl(
                source, (EntityIdent)args[0]
            );
            return;

        case OrthSceneMarshaller.SEND_SPRITE_MESSAGE:
            ((OrthSceneProvider)provider).sendSpriteMessage(
                source, (EntityIdent)args[0], (String)args[1], (byte[])args[2], ((Boolean)args[3]).booleanValue()
            );
            return;

        case OrthSceneMarshaller.SEND_SPRITE_SIGNAL:
            ((OrthSceneProvider)provider).sendSpriteSignal(
                source, (String)args[0], (byte[])args[1]
            );
            return;

        case OrthSceneMarshaller.SET_ACTOR_STATE:
            ((OrthSceneProvider)provider).setActorState(
                source, (EntityIdent)args[0], ((Integer)args[1]).intValue(), (String)args[2]
            );
            return;

        case OrthSceneMarshaller.UPDATE_MEMORY:
            ((OrthSceneProvider)provider).updateMemory(
                source, (EntityIdent)args[0], (String)args[1], (byte[])args[2], (InvocationService.ResultListener)args[3]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
