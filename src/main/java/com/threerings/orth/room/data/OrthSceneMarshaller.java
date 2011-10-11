//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import javax.annotation.Generated;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.whirled.client.SceneService;
import com.threerings.whirled.data.SceneMarshaller;

import com.threerings.orth.room.client.OrthSceneService;

/**
 * Provides the implementation of the {@link OrthSceneService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from OrthSceneService.java.")
public class OrthSceneMarshaller extends InvocationMarshaller<ClientObject>
    implements OrthSceneService
{
    /** The method id used to dispatch {@link #moveTo} requests. */
    public static final int MOVE_TO = 1;

    // from interface OrthSceneService
    public void moveTo (RoomLocus arg1, int arg2, int arg3, SceneService.SceneMoveListener arg4)
    {
        SceneMarshaller.SceneMoveMarshaller listener4 = new SceneMarshaller.SceneMoveMarshaller();
        listener4.listener = arg4;
        sendRequest(MOVE_TO, new Object[] {
            arg1, Integer.valueOf(arg2), Integer.valueOf(arg3), listener4
        });
    }
}
