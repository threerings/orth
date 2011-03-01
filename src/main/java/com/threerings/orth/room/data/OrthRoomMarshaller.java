//
// $Id$
package com.threerings.orth.room.data;

import javax.annotation.Generated;

import com.threerings.orth.room.client.OrthRoomService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.whirled.data.SceneUpdate;
import com.threerings.whirled.spot.data.Location;

/**
 * Provides the implementation of the {@link OrthRoomService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from OrthRoomService.java.")
public class OrthRoomMarshaller extends InvocationMarshaller
    implements OrthRoomService
{
    /** The method id used to dispatch {@link #changeLocation} requests. */
    public static final int CHANGE_LOCATION = 1;

    // from interface OrthRoomService
    public void changeLocation (EntityIdent arg1, Location arg2)
    {
        sendRequest(CHANGE_LOCATION, new Object[] {
            arg1, arg2
        });
    }

    /** The method id used to dispatch {@link #editRoom} requests. */
    public static final int EDIT_ROOM = 2;

    // from interface OrthRoomService
    public void editRoom (InvocationService.ResultListener arg1)
    {
        InvocationMarshaller.ResultMarshaller listener1 = new InvocationMarshaller.ResultMarshaller();
        listener1.listener = arg1;
        sendRequest(EDIT_ROOM, new Object[] {
            listener1
        });
    }

    /** The method id used to dispatch {@link #sendSpriteMessage} requests. */
    public static final int SEND_SPRITE_MESSAGE = 3;

    // from interface OrthRoomService
    public void sendSpriteMessage (EntityIdent arg1, String arg2, byte[] arg3, boolean arg4)
    {
        sendRequest(SEND_SPRITE_MESSAGE, new Object[] {
            arg1, arg2, arg3, Boolean.valueOf(arg4)
        });
    }

    /** The method id used to dispatch {@link #sendSpriteSignal} requests. */
    public static final int SEND_SPRITE_SIGNAL = 4;

    // from interface OrthRoomService
    public void sendSpriteSignal (String arg1, byte[] arg2)
    {
        sendRequest(SEND_SPRITE_SIGNAL, new Object[] {
            arg1, arg2
        });
    }

    /** The method id used to dispatch {@link #setActorState} requests. */
    public static final int SET_ACTOR_STATE = 5;

    // from interface OrthRoomService
    public void setActorState (EntityIdent arg1, int arg2, String arg3)
    {
        sendRequest(SET_ACTOR_STATE, new Object[] {
            arg1, Integer.valueOf(arg2), arg3
        });
    }

    /** The method id used to dispatch {@link #updateMemory} requests. */
    public static final int UPDATE_MEMORY = 6;

    // from interface OrthRoomService
    public void updateMemory (EntityIdent arg1, String arg2, byte[] arg3, InvocationService.ResultListener arg4)
    {
        InvocationMarshaller.ResultMarshaller listener4 = new InvocationMarshaller.ResultMarshaller();
        listener4.listener = arg4;
        sendRequest(UPDATE_MEMORY, new Object[] {
            arg1, arg2, arg3, listener4
        });
    }

    /** The method id used to dispatch {@link #updateRoom} requests. */
    public static final int UPDATE_ROOM = 7;

    // from interface OrthRoomService
    public void updateRoom (SceneUpdate arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(UPDATE_ROOM, new Object[] {
            arg1, listener2
        });
    }
}
