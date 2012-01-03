//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.data {

import com.threerings.util.Integer;

import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.guild.client.GuildService;

/**
 * Provides the implementation of the <code>GuildService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class GuildMarshaller extends InvocationMarshaller
    implements GuildService
{
    /** The method id used to dispatch <code>disband</code> requests. */
    public static const DISBAND :int = 1;

    // from interface GuildService
    public function disband (arg1 :InvocationService_InvocationListener) :void
    {
        var listener1 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener1.listener = arg1;
        sendRequest(DISBAND, [
            listener1
        ]);
    }

    /** The method id used to dispatch <code>leave</code> requests. */
    public static const LEAVE :int = 2;

    // from interface GuildService
    public function leave (arg1 :InvocationService_InvocationListener) :void
    {
        var listener1 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener1.listener = arg1;
        sendRequest(LEAVE, [
            listener1
        ]);
    }

    /** The method id used to dispatch <code>remove</code> requests. */
    public static const REMOVE :int = 3;

    // from interface GuildService
    public function remove (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(REMOVE, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>sendInvite</code> requests. */
    public static const SEND_INVITE :int = 4;

    // from interface GuildService
    public function sendInvite (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(SEND_INVITE, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>updateRank</code> requests. */
    public static const UPDATE_RANK :int = 5;

    // from interface GuildService
    public function updateRank (arg1 :int, arg2 :GuildRank, arg3 :InvocationService_InvocationListener) :void
    {
        var listener3 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(UPDATE_RANK, [
            Integer.valueOf(arg1), arg2, listener3
        ]);
    }
}
}
