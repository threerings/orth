//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import javax.annotation.Generated;

import com.threerings.orth.room.client.OrthSceneService;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.whirled.client.SceneService;
import com.threerings.whirled.data.SceneMarshaller;

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
    /** The method id used to dispatch {@link #moveTo} requests. */
    public static final int MOVE_TO = 1;

    // from interface OrthSceneService
    public void moveTo (int arg1, int arg2, int arg3, OrthLocation arg4, SceneService.SceneMoveListener arg5)
    {
        SceneMarshaller.SceneMoveMarshaller listener5 = new SceneMarshaller.SceneMoveMarshaller();
        listener5.listener = arg5;
        sendRequest(MOVE_TO, new Object[] {
            Integer.valueOf(arg1), Integer.valueOf(arg2), Integer.valueOf(arg3), arg4, listener5
        });
    }
}
