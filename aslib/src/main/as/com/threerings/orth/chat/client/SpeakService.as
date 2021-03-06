//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java SpeakService interface.
 */
public interface SpeakService extends InvocationService
{
    // from Java interface SpeakService
    function speak (arg1 :String, arg2 :InvocationService_InvocationListener) :void;
}
}
