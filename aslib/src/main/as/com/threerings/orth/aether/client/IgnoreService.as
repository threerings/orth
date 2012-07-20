//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java IgnoreService interface.
 */
public interface IgnoreService extends InvocationService
{
    // from Java interface IgnoreService
    function ignorePlayer (arg1 :int, arg2 :Boolean, arg3 :InvocationService_InvocationListener) :void;
}
}
