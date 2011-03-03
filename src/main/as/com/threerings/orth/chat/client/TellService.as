//
// $Id$
package com.threerings.orth.chat.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ConfirmListener;

/**
 * An ActionScript version of the Java TellService interface.
 */
public interface TellService extends InvocationService
{
    // from Java interface TellService
    function sendTell (arg1 :int, arg2 :String, arg3 :InvocationService_ConfirmListener) :void;
}
}
