//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ConfirmListener;

import com.threerings.orth.data.PlayerName;

/**
 * An ActionScript version of the Java TellService interface.
 */
public interface TellService extends InvocationService
{
    // from Java interface TellService
    function sendTell (arg1 :PlayerName, arg2 :String, arg3 :InvocationService_ConfirmListener) :void;
}
}
