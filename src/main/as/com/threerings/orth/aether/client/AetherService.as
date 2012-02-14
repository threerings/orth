//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java AetherService interface.
 */
public interface AetherService extends InvocationService
{
    // from Java interface AetherService
    function acceptGuildInvite (arg1 :int, arg2 :int, arg3 :InvocationService_InvocationListener) :void;

    // from Java interface AetherService
    function createGuild (arg1 :String, arg2 :InvocationService_ConfirmListener) :void;
}
}
