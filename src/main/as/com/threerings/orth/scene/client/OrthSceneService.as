//
// $Id$

package com.threerings.orth.scene.client {

import com.threerings.io.TypedArray;
import com.threerings.orth.scene.data.EntityIdent;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.whirled.data.SceneUpdate;

/**
 * An ActionScript version of the Java RoomService interface.
 */
public interface OrthSceneService extends InvocationService
{
    // from Java interface RoomService
    function editRoom (arg1 :InvocationService_ResultListener) :void;

    // from Java interface RoomService
    function jumpToSong (arg1 :int, arg2 :InvocationService_ConfirmListener) :void;

    // from Java interface RoomService
    function modifyPlaylist (arg1 :int, arg2 :Boolean, arg3 :InvocationService_ConfirmListener) :void;

    // from Java interface RoomService
    function publishRoom (arg1 :InvocationService_InvocationListener) :void;

    // from Java interface RoomService
    function rateRoom (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface RoomService
    function requestControl (arg1 :EntityIdent) :void;

    // from Java interface RoomService
    function sendPostcard (arg1 :TypedArray /* of class java.lang.String */, arg2 :String, arg3 :String, arg4 :String, arg5 :InvocationService_ConfirmListener) :void;

    // from Java interface RoomService
    function songEnded (arg1 :int) :void;

    // from Java interface RoomService
    function updateRoom (arg1 :SceneUpdate, arg2 :InvocationService_InvocationListener) :void;
}
}
