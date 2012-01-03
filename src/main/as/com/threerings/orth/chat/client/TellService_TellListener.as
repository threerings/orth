//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.client {

import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java TellService_TellListener interface.
 */
public interface TellService_TellListener
    extends InvocationService_InvocationListener
{
    // from Java TellService_TellListener
    function tellSucceeded () :void
}
}
