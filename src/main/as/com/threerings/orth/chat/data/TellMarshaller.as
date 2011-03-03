//
// $Id$
package com.threerings.orth.chat.data {

import com.threerings.util.Integer;

import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ConfirmMarshaller;

import com.threerings.orth.chat.client.TellService;

/**
 * Provides the implementation of the <code>TellService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class TellMarshaller extends InvocationMarshaller
    implements TellService
{
    /** The method id used to dispatch <code>sendTell</code> requests. */
    public static const SEND_TELL :int = 1;

    // from interface TellService
    public function sendTell (arg1 :int, arg2 :String, arg3 :InvocationService_ConfirmListener) :void
    {
        var listener3 :InvocationMarshaller_ConfirmMarshaller = new InvocationMarshaller_ConfirmMarshaller();
        listener3.listener = arg3;
        sendRequest(SEND_TELL, [
            Integer.valueOf(arg1), arg2, listener3
        ]);
    }
}
}
