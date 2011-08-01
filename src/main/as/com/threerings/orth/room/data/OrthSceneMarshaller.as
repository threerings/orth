//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data {

import com.threerings.util.Integer;

import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.whirled.client.SceneService_SceneMoveListener;
import com.threerings.whirled.data.SceneMarshaller_SceneMoveMarshaller;

import com.threerings.orth.room.client.OrthSceneService;

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
    /** The method id used to dispatch <code>moveTo</code> requests. */
    public static const MOVE_TO :int = 1;

    // from interface OrthSceneService
    public function moveTo (arg1 :int, arg2 :int, arg3 :int, arg4 :OrthLocation, arg5 :SceneService_SceneMoveListener) :void
    {
        var listener5 :SceneMarshaller_SceneMoveMarshaller = new SceneMarshaller_SceneMoveMarshaller();
        listener5.listener = arg5;
        sendRequest(MOVE_TO, [
            Integer.valueOf(arg1), Integer.valueOf(arg2), Integer.valueOf(arg3), arg4, listener5
        ]);
    }
}
}
