//
// $Id$
package com.threerings.orth.chat.data;

import javax.annotation.Generated;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.chat.client.TellService;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.dobj.InvocationResponseEvent;

/**
 * Provides the implementation of the {@link TellService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from TellService.java.")
public class TellMarshaller extends InvocationMarshaller
    implements TellService
{
    /**
     * Marshalls results to implementations of {@link TellService.TellResultListener}.
     */
    public static class TellResultMarshaller extends ListenerMarshaller
        implements TellResultListener
    {
        /** The method id used to dispatch {@link #tellSucceeded}
         * responses. */
        public static final int TELL_SUCCEEDED = 1;

        // from interface TellResultMarshaller
        public void tellSucceeded ()
        {
            _invId = null;
            omgr.postEvent(new InvocationResponseEvent(
                               callerOid, requestId, TELL_SUCCEEDED,
                               new Object[] {  }, transport));
        }

        @Override // from InvocationMarshaller
        public void dispatchResponse (int methodId, Object[] args)
        {
            switch (methodId) {
            case TELL_SUCCEEDED:
                ((TellResultListener)listener).tellSucceeded(
                    );
                return;

            default:
                super.dispatchResponse(methodId, args);
                return;
            }
        }
    }

    /** The method id used to dispatch {@link #sendTell} requests. */
    public static final int SEND_TELL = 1;

    // from interface TellService
    public void sendTell (PlayerName arg1, String arg2, TellService.TellResultListener arg3)
    {
        TellMarshaller.TellResultMarshaller listener3 = new TellMarshaller.TellResultMarshaller();
        listener3.listener = arg3;
        sendRequest(SEND_TELL, new Object[] {
            arg1, arg2, listener3
        });
    }
}
