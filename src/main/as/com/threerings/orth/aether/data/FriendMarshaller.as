//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.data {

import com.threerings.util.Integer;

import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.aether.client.FriendService;

/**
 * Provides the implementation of the <code>FriendService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class FriendMarshaller extends InvocationMarshaller
    implements FriendService
{
    /** The method id used to dispatch <code>acceptFriendshipRequest</code> requests. */
    public static const ACCEPT_FRIENDSHIP_REQUEST :int = 1;

    // from interface FriendService
    public function acceptFriendshipRequest (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(ACCEPT_FRIENDSHIP_REQUEST, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>requestFriendship</code> requests. */
    public static const REQUEST_FRIENDSHIP :int = 2;

    // from interface FriendService
    public function requestFriendship (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(REQUEST_FRIENDSHIP, [
            Integer.valueOf(arg1), listener2
        ]);
    }
}
}
