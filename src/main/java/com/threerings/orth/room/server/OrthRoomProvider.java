//
// $Id$

package com.threerings.orth.room.server;

import javax.annotation.Generated;

import com.threerings.orth.room.client.OrthRoomService;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;
import com.threerings.whirled.spot.data.Location;

/**
 * Defines the server-side of the {@link OrthRoomService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from OrthRoomService.java.")
public interface OrthRoomProvider extends InvocationProvider
{
    /**
     * Handles a {@link OrthRoomService#changeLocation} request.
     */
    void changeLocation (ClientObject caller, EntityIdent arg1, Location arg2);

    /**
     * Handles a {@link OrthRoomService#sendSpriteMessage} request.
     */
    void sendSpriteMessage (ClientObject caller, EntityIdent arg1, String arg2, byte[] arg3, boolean arg4);

    /**
     * Handles a {@link OrthRoomService#sendSpriteSignal} request.
     */
    void sendSpriteSignal (ClientObject caller, String arg1, byte[] arg2);

    /**
     * Handles a {@link OrthRoomService#setActorState} request.
     */
    void setActorState (ClientObject caller, EntityIdent arg1, int arg2, String arg3);

    /**
     * Handles a {@link OrthRoomService#updateMemory} request.
     */
    void updateMemory (ClientObject caller, EntityIdent arg1, String arg2, byte[] arg3, InvocationService.ResultListener arg4)
        throws InvocationException;
}
