//
// $Id$
package com.threerings.orth.chat.data {

import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.orth.chat.client.SpeakService;

/**
 * Provides the implementation of the <code>SpeakService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class SpeakMarshaller extends InvocationMarshaller
    implements SpeakService
{
    /** The method id used to dispatch <code>speak</code> requests. */
    public static const SPEAK :int = 1;

    // from interface SpeakService
    public function speak (arg1 :String) :void
    {
        sendRequest(SPEAK, [
            arg1
        ]);
    }
}
}
