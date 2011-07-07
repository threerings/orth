//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.orth.aether.client.FriendService;

/**
 * Provides the implementation of the {@link FriendService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from FriendService.java.")
public class FriendMarshaller extends InvocationMarshaller<AetherClientObject>
    implements FriendService
{
    /** The method id used to dispatch {@link #acceptFriendshipRequest} requests. */
    public static final int ACCEPT_FRIENDSHIP_REQUEST = 1;

    // from interface FriendService
    public void acceptFriendshipRequest (int arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(ACCEPT_FRIENDSHIP_REQUEST, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #requestFriendship} requests. */
    public static final int REQUEST_FRIENDSHIP = 2;

    // from interface FriendService
    public void requestFriendship (int arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(REQUEST_FRIENDSHIP, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }
}
