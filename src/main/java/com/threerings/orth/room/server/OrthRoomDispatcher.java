//
// $Id$

package com.threerings.orth.room.server;

import javax.annotation.Generated;

import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.OrthRoomMarshaller;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;
import com.threerings.whirled.spot.data.Location;

/**
 * Dispatches requests to the {@link OrthRoomProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from OrthRoomService.java.")
public class OrthRoomDispatcher extends InvocationDispatcher<OrthRoomMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public OrthRoomDispatcher (OrthRoomProvider provider)
    {
        this.provider = provider;
    }

    @Override
    public OrthRoomMarshaller createMarshaller ()
    {
        return new OrthRoomMarshaller();
    }

    @Override
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case OrthRoomMarshaller.CHANGE_LOCATION:
            ((OrthRoomProvider)provider).changeLocation(
                source, (EntityIdent)args[0], (Location)args[1]
            );
            return;

        case OrthRoomMarshaller.SEND_SPRITE_MESSAGE:
            ((OrthRoomProvider)provider).sendSpriteMessage(
                source, (EntityIdent)args[0], (String)args[1], (byte[])args[2], ((Boolean)args[3]).booleanValue()
            );
            return;

        case OrthRoomMarshaller.SEND_SPRITE_SIGNAL:
            ((OrthRoomProvider)provider).sendSpriteSignal(
                source, (String)args[0], (byte[])args[1]
            );
            return;

        case OrthRoomMarshaller.SET_ACTOR_STATE:
            ((OrthRoomProvider)provider).setActorState(
                source, (EntityIdent)args[0], ((Integer)args[1]).intValue(), (String)args[2]
            );
            return;

        case OrthRoomMarshaller.UPDATE_MEMORY:
            ((OrthRoomProvider)provider).updateMemory(
                source, (EntityIdent)args[0], (String)args[1], (byte[])args[2], (InvocationService.ResultListener)args[3]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
