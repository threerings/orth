//
// $Id$
package com.threerings.orth.chat.data;

import javax.annotation.Generated;

import com.threerings.orth.chat.client.SpeakService;
import com.threerings.presents.data.InvocationMarshaller;

/**
 * Provides the implementation of the {@link SpeakService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from SpeakService.java.")
public class SpeakMarshaller extends InvocationMarshaller
    implements SpeakService
{
    /** The method id used to dispatch {@link #speak} requests. */
    public static final int SPEAK = 1;

    // from interface SpeakService
    public void speak (String arg1)
    {
        sendRequest(SPEAK, new Object[] {
            arg1
        });
    }
}
