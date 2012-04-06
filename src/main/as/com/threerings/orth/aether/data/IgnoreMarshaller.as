//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.data {

import com.threerings.util.Integer;
import com.threerings.util.langBoolean;

import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.aether.client.IgnoreService;

/**
 * Provides the implementation of the <code>IgnoreService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class IgnoreMarshaller extends InvocationMarshaller
    implements IgnoreService
{
    /** The method id used to dispatch <code>ignorePlayer</code> requests. */
    public static const IGNORE_PLAYER :int = 1;

    // from interface IgnoreService
    public function ignorePlayer (arg1 :int, arg2 :Boolean, arg3 :InvocationService_InvocationListener) :void
    {
        var listener3 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(IGNORE_PLAYER, [
            Integer.valueOf(arg1), langBoolean.valueOf(arg2), listener3
        ]);
    }
}
}
