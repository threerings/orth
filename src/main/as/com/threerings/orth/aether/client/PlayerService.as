//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java PlayerService interface.
 */
public interface PlayerService extends InvocationService
{
    // from Java interface PlayerService
    function acceptGuildInvite (arg1 :int, arg2 :int, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface PlayerService
    function createGuild (arg1 :String, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface PlayerService
    function dispatchDeferredNotifications () :void;
}
}
