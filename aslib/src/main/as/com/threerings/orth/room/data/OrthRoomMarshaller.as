//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data {

import flash.utils.ByteArray;

import com.threerings.util.Integer;
import com.threerings.util.langBoolean;

import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ResultMarshaller;

import com.threerings.whirled.data.SceneUpdate;
import com.threerings.whirled.spot.data.Location;

import com.threerings.orth.room.client.OrthRoomService;

/**
 * Provides the implementation of the <code>OrthRoomService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class OrthRoomMarshaller extends InvocationMarshaller
    implements OrthRoomService
{
    /** The method id used to dispatch <code>changeLocation</code> requests. */
    public static const CHANGE_LOCATION :int = 1;

    // from interface OrthRoomService
    public function changeLocation (arg1 :EntityIdent, arg2 :Location) :void
    {
        sendRequest(CHANGE_LOCATION, [
            arg1, arg2
        ]);
    }

    /** The method id used to dispatch <code>editRoom</code> requests. */
    public static const EDIT_ROOM :int = 2;

    // from interface OrthRoomService
    public function editRoom (arg1 :InvocationService_ResultListener) :void
    {
        var listener1 :InvocationMarshaller_ResultMarshaller = new InvocationMarshaller_ResultMarshaller();
        listener1.listener = arg1;
        sendRequest(EDIT_ROOM, [
            listener1
        ]);
    }

    /** The method id used to dispatch <code>sendSpriteMessage</code> requests. */
    public static const SEND_SPRITE_MESSAGE :int = 3;

    // from interface OrthRoomService
    public function sendSpriteMessage (arg1 :EntityIdent, arg2 :String, arg3 :ByteArray, arg4 :Boolean) :void
    {
        sendRequest(SEND_SPRITE_MESSAGE, [
            arg1, arg2, arg3, langBoolean.valueOf(arg4)
        ]);
    }

    /** The method id used to dispatch <code>sendSpriteSignal</code> requests. */
    public static const SEND_SPRITE_SIGNAL :int = 4;

    // from interface OrthRoomService
    public function sendSpriteSignal (arg1 :String, arg2 :ByteArray) :void
    {
        sendRequest(SEND_SPRITE_SIGNAL, [
            arg1, arg2
        ]);
    }

    /** The method id used to dispatch <code>setActorState</code> requests. */
    public static const SET_ACTOR_STATE :int = 5;

    // from interface OrthRoomService
    public function setActorState (arg1 :EntityIdent, arg2 :int, arg3 :String) :void
    {
        sendRequest(SET_ACTOR_STATE, [
            arg1, Integer.valueOf(arg2), arg3
        ]);
    }

    /** The method id used to dispatch <code>updateMemory</code> requests. */
    public static const UPDATE_MEMORY :int = 6;

    // from interface OrthRoomService
    public function updateMemory (arg1 :EntityIdent, arg2 :String, arg3 :ByteArray, arg4 :InvocationService_ResultListener) :void
    {
        var listener4 :InvocationMarshaller_ResultMarshaller = new InvocationMarshaller_ResultMarshaller();
        listener4.listener = arg4;
        sendRequest(UPDATE_MEMORY, [
            arg1, arg2, arg3, listener4
        ]);
    }

    /** The method id used to dispatch <code>updateRoom</code> requests. */
    public static const UPDATE_ROOM :int = 7;

    // from interface OrthRoomService
    public function updateRoom (arg1 :SceneUpdate, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(UPDATE_ROOM, [
            arg1, listener2
        ]);
    }
}
}
