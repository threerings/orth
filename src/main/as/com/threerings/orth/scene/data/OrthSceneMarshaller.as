//
// $Id$
//
// Orth library - tools for developing networked games
// Copyright (C) 2002-2010 Three Rings Design, Inc., All Rights Reserved
// http://www.threerings.net/code/nenya/
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

package com.threerings.orth.scene.data {

import com.threerings.orth.entity.client.OrthSceneService;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ResultMarshaller;
import com.threerings.util.Integer;
import com.threerings.util.langBoolean;
import com.threerings.whirled.spot.data.Location;
import flash.utils.ByteArray;

/**
 * Provides the implementation of the <code>OrthSceneService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class OrthSceneMarshaller extends InvocationMarshaller
    implements OrthSceneService
{
    /** The method id used to dispatch <code>changeLocation</code> requests. */
    public static const CHANGE_LOCATION :int = 1;

    // from interface OrthSceneService
    public function changeLocation (arg1 :EntityIdent, arg2 :Location) :void
    {
        sendRequest(CHANGE_LOCATION, [
            arg1, arg2
        ]);
    }

    /** The method id used to dispatch <code>requestControl</code> requests. */
    public static const REQUEST_CONTROL :int = 2;

    // from interface OrthSceneService
    public function requestControl (arg1 :EntityIdent) :void
    {
        sendRequest(REQUEST_CONTROL, [
            arg1
        ]);
    }

    /** The method id used to dispatch <code>sendSpriteMessage</code> requests. */
    public static const SEND_SPRITE_MESSAGE :int = 3;

    // from interface OrthSceneService
    public function sendSpriteMessage (arg1 :EntityIdent, arg2 :String, arg3 :ByteArray, arg4 :Boolean) :void
    {
        sendRequest(SEND_SPRITE_MESSAGE, [
            arg1, arg2, arg3, langBoolean.valueOf(arg4)
        ]);
    }

    /** The method id used to dispatch <code>sendSpriteSignal</code> requests. */
    public static const SEND_SPRITE_SIGNAL :int = 4;

    // from interface OrthSceneService
    public function sendSpriteSignal (arg1 :String, arg2 :ByteArray) :void
    {
        sendRequest(SEND_SPRITE_SIGNAL, [
            arg1, arg2
        ]);
    }

    /** The method id used to dispatch <code>setActorState</code> requests. */
    public static const SET_ACTOR_STATE :int = 5;

    // from interface OrthSceneService
    public function setActorState (arg1 :EntityIdent, arg2 :int, arg3 :String) :void
    {
        sendRequest(SET_ACTOR_STATE, [
            arg1, Integer.valueOf(arg2), arg3
        ]);
    }

    /** The method id used to dispatch <code>updateMemory</code> requests. */
    public static const UPDATE_MEMORY :int = 6;

    // from interface OrthSceneService
    public function updateMemory (arg1 :EntityIdent, arg2 :String, arg3 :ByteArray, arg4 :InvocationService_ResultListener) :void
    {
        var listener4 :InvocationMarshaller_ResultMarshaller = new InvocationMarshaller_ResultMarshaller();
        listener4.listener = arg4;
        sendRequest(UPDATE_MEMORY, [
            arg1, arg2, arg3, listener4
        ]);
    }
}
}
