//
// $Id$

package com.threerings.orth.scene.client {

import com.threerings.orth.scene.data.EntityIdent;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.whirled.spot.data.Location;
import flash.utils.ByteArray;

/**
 * An ActionScript version of the Java OrthSceneService interface.
 */
public interface OrthSceneService extends InvocationService
{
    // from Java interface OrthSceneService
    function changeLocation (arg1 :EntityIdent, arg2 :Location) :void;

    // from Java interface OrthSceneService
    function requestControl (arg1 :EntityIdent) :void;

    // from Java interface OrthSceneService
    function sendSpriteMessage (arg1 :EntityIdent, arg2 :String, arg3 :ByteArray, arg4 :Boolean) :void;

    // from Java interface OrthSceneService
    function sendSpriteSignal (arg1 :String, arg2 :ByteArray) :void;

    // from Java interface OrthSceneService
    function setActorState (arg1 :EntityIdent, arg2 :int, arg3 :String) :void;

    // from Java interface OrthSceneService
    function updateMemory (arg1 :EntityIdent, arg2 :String, arg3 :ByteArray, arg4 :InvocationService_ResultListener) :void;
}
}
