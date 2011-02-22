//
// $Id$
package com.threerings.orth.chat.client {

import com.threerings.presents.client.InvocationService;

import com.threerings.orth.aether.data.PlayerName;

/**
 * An ActionScript version of the Java TellService interface.
 */
public interface TellService extends InvocationService
{
    // from Java interface TellService
    function sendTell (arg1 :PlayerName, arg2 :String, arg3 :TellService_TellResultListener) :void;
}
}
