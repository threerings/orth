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

package com.threerings.orth.scene.data;

import javax.annotation.Generated;

import com.threerings.orth.scene.client.OrthSceneService;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.whirled.spot.data.Location;

/**
 * Provides the implementation of the {@link OrthSceneService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from OrthSceneService.java.")
public class OrthSceneMarshaller extends InvocationMarshaller
    implements OrthSceneService
{
    /** The method id used to dispatch {@link #changeLocation} requests. */
    public static final int CHANGE_LOCATION = 1;

    // from interface OrthSceneService
    public void changeLocation (Client arg1, EntityIdent arg2, Location arg3)
    {
        sendRequest(arg1, CHANGE_LOCATION, new Object[] {
            arg2, arg3
        });
    }

    /** The method id used to dispatch {@link #requestControl} requests. */
    public static final int REQUEST_CONTROL = 2;

    // from interface OrthSceneService
    public void requestControl (Client arg1, EntityIdent arg2)
    {
        sendRequest(arg1, REQUEST_CONTROL, new Object[] {
            arg2
        });
    }

    /** The method id used to dispatch {@link #sendSpriteMessage} requests. */
    public static final int SEND_SPRITE_MESSAGE = 3;

    // from interface OrthSceneService
    public void sendSpriteMessage (Client arg1, EntityIdent arg2, String arg3, byte[] arg4, boolean arg5)
    {
        sendRequest(arg1, SEND_SPRITE_MESSAGE, new Object[] {
            arg2, arg3, arg4, Boolean.valueOf(arg5)
        });
    }

    /** The method id used to dispatch {@link #sendSpriteSignal} requests. */
    public static final int SEND_SPRITE_SIGNAL = 4;

    // from interface OrthSceneService
    public void sendSpriteSignal (Client arg1, String arg2, byte[] arg3)
    {
        sendRequest(arg1, SEND_SPRITE_SIGNAL, new Object[] {
            arg2, arg3
        });
    }

    /** The method id used to dispatch {@link #setActorState} requests. */
    public static final int SET_ACTOR_STATE = 5;

    // from interface OrthSceneService
    public void setActorState (Client arg1, EntityIdent arg2, int arg3, String arg4)
    {
        sendRequest(arg1, SET_ACTOR_STATE, new Object[] {
            arg2, Integer.valueOf(arg3), arg4
        });
    }

    /** The method id used to dispatch {@link #updateMemory} requests. */
    public static final int UPDATE_MEMORY = 6;

    // from interface OrthSceneService
    public void updateMemory (Client arg1, EntityIdent arg2, String arg3, byte[] arg4, InvocationService.ResultListener arg5)
    {
        InvocationMarshaller.ResultMarshaller listener5 = new InvocationMarshaller.ResultMarshaller();
        listener5.listener = arg5;
        sendRequest(arg1, UPDATE_MEMORY, new Object[] {
            arg2, arg3, arg4, listener5
        });
    }
}
