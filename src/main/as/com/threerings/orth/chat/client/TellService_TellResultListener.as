//
// $Id$
package com.threerings.orth.chat.client {

import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java TellService_TellResultListener interface.
 */
public interface TellService_TellResultListener
    extends InvocationService_InvocationListener
{
    // from Java TellService_TellResultListener
    function tellSucceeded () :void
}
}
