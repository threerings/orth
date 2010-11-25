//
// $Id$

package com.threerings.orth.room.data;

import javax.annotation.Generated;

import com.threerings.orth.room.client.OrthRoomService;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.whirled.spot.data.Location;

/**
 * Provides the implementation of the {@link com.threerings.orth.room.client.OrthRoomService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from OrthRoomService.java.")
public class OrthSceneMarshaller extends InvocationMarshaller
    implements OrthRoomService
{
    /** The method id used to dispatch {@link #changeLocation} requests. */
    public static final int CHANGE_LOCATION = 1;

    // from interface OrthRoomService
    public void changeLocation (Client arg1, EntityIdent arg2, Location arg3)
    {
        sendRequest(arg1, CHANGE_LOCATION, new Object[] {
            arg2, arg3
        });
    }

    /** The method id used to dispatch {@link #requestControl} requests. */
    public static final int REQUEST_CONTROL = 2;

    // from interface OrthRoomService
    public void requestControl (Client arg1, EntityIdent arg2)
    {
        sendRequest(arg1, REQUEST_CONTROL, new Object[] {
            arg2
        });
    }

    /** The method id used to dispatch {@link #sendSpriteMessage} requests. */
    public static final int SEND_SPRITE_MESSAGE = 3;

    // from interface OrthRoomService
    public void sendSpriteMessage (Client arg1, EntityIdent arg2, String arg3, byte[] arg4, boolean arg5)
    {
        sendRequest(arg1, SEND_SPRITE_MESSAGE, new Object[] {
            arg2, arg3, arg4, Boolean.valueOf(arg5)
        });
    }

    /** The method id used to dispatch {@link #sendSpriteSignal} requests. */
    public static final int SEND_SPRITE_SIGNAL = 4;

    // from interface OrthRoomService
    public void sendSpriteSignal (Client arg1, String arg2, byte[] arg3)
    {
        sendRequest(arg1, SEND_SPRITE_SIGNAL, new Object[] {
            arg2, arg3
        });
    }

    /** The method id used to dispatch {@link #setActorState} requests. */
    public static final int SET_ACTOR_STATE = 5;

    // from interface OrthRoomService
    public void setActorState (Client arg1, EntityIdent arg2, int arg3, String arg4)
    {
        sendRequest(arg1, SET_ACTOR_STATE, new Object[] {
            arg2, Integer.valueOf(arg3), arg4
        });
    }

    /** The method id used to dispatch {@link #updateMemory} requests. */
    public static final int UPDATE_MEMORY = 6;

    // from interface OrthRoomService
    public void updateMemory (Client arg1, EntityIdent arg2, String arg3, byte[] arg4, InvocationService.ResultListener arg5)
    {
        InvocationMarshaller.ResultMarshaller listener5 = new InvocationMarshaller.ResultMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, UPDATE_MEMORY, new Object[] {
            arg2, arg3, arg4, listener5
        });
    }
}
