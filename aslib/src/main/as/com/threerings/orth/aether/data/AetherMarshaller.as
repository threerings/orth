//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.data {

import com.threerings.util.Integer;

import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ConfirmMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.aether.client.AetherService;

/**
 * Provides the implementation of the <code>AetherService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class AetherMarshaller extends InvocationMarshaller
    implements AetherService
{
    /** The method id used to dispatch <code>acceptGuildInvite</code> requests. */
    public static const ACCEPT_GUILD_INVITE :int = 1;

    // from interface AetherService
    public function acceptGuildInvite (arg1 :int, arg2 :int, arg3 :InvocationService_InvocationListener) :void
    {
        var listener3 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(ACCEPT_GUILD_INVITE, [
            Integer.valueOf(arg1), Integer.valueOf(arg2), listener3
        ]);
    }

    /** The method id used to dispatch <code>createGuild</code> requests. */
    public static const CREATE_GUILD :int = 2;

    // from interface AetherService
    public function createGuild (arg1 :String, arg2 :InvocationService_ConfirmListener) :void
    {
        var listener2 :InvocationMarshaller_ConfirmMarshaller = new InvocationMarshaller_ConfirmMarshaller();
        listener2.listener = arg2;
        sendRequest(CREATE_GUILD, [
            arg1, listener2
        ]);
    }
}
}
