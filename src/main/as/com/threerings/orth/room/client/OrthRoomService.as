//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client {

import flash.utils.ByteArray;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;

import com.threerings.whirled.data.SceneUpdate;
import com.threerings.whirled.spot.data.Location;

import com.threerings.orth.room.data.EntityIdent;

/**
 * An ActionScript version of the Java OrthRoomService interface.
 */
public interface OrthRoomService extends InvocationService
{
    // from Java interface OrthRoomService
    function changeLocation (arg1 :EntityIdent, arg2 :Location) :void;

    // from Java interface OrthRoomService
    function editRoom (arg1 :InvocationService_ResultListener) :void;

    // from Java interface OrthRoomService
    function sendSpriteMessage (arg1 :EntityIdent, arg2 :String, arg3 :ByteArray, arg4 :Boolean) :void;

    // from Java interface OrthRoomService
    function sendSpriteSignal (arg1 :String, arg2 :ByteArray) :void;

    // from Java interface OrthRoomService
    function setActorState (arg1 :EntityIdent, arg2 :int, arg3 :String) :void;

    // from Java interface OrthRoomService
    function updateMemory (arg1 :EntityIdent, arg2 :String, arg3 :ByteArray, arg4 :InvocationService_ResultListener) :void;

    // from Java interface OrthRoomService
    function updateRoom (arg1 :SceneUpdate, arg2 :InvocationService_InvocationListener) :void;
}
}
