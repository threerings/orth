//
// $Id$
package com.threerings.orth.world.data;

import javax.annotation.Generated;

import com.threerings.orth.world.client.WorldService;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.dobj.InvocationResponseEvent;

/**
 * Provides the implementation of the {@link WorldService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from WorldService.java.")
public class WorldMarshaller extends InvocationMarshaller
    implements WorldService
{
    /**
     * Marshalls results to implementations of {@link WorldService.PlaceResolutionListener}.
     */
    public static class PlaceResolutionMarshaller extends ListenerMarshaller
        implements PlaceResolutionListener
    {
        /** The method id used to dispatch {@link #placeLocated}
         * responses. */
        public static final int PLACE_LOCATED = 1;

        // from interface PlaceResolutionMarshaller
        public void placeLocated (OrthPlace arg1)
        {
            _invId = null;
            omgr.postEvent(new InvocationResponseEvent(
                               callerOid, requestId, PLACE_LOCATED,
                               new Object[] { arg1 }, transport));
        }

        /** The method id used to dispatch {@link #resolutionFailed}
         * responses. */
        public static final int RESOLUTION_FAILED = 2;

        // from interface PlaceResolutionMarshaller
        public void resolutionFailed (PlaceKey arg1, String arg2)
        {
            _invId = null;
            omgr.postEvent(new InvocationResponseEvent(
                               callerOid, requestId, RESOLUTION_FAILED,
                               new Object[] { arg1, arg2 }, transport));
        }

        @Override // from InvocationMarshaller
        public void dispatchResponse (int methodId, Object[] args)
        {
            switch (methodId) {
            case PLACE_LOCATED:
                ((PlaceResolutionListener)listener).placeLocated(
                    (OrthPlace)args[0]);
                return;

            case RESOLUTION_FAILED:
                ((PlaceResolutionListener)listener).resolutionFailed(
                    (PlaceKey)args[0], (String)args[1]);
                return;

            default:
                super.dispatchResponse(methodId, args);
                return;
            }
        }
    }

    /** The method id used to dispatch {@link #locatePlace} requests. */
    public static final int LOCATE_PLACE = 1;

    // from interface WorldService
    public void locatePlace (PlaceKey arg1, WorldService.PlaceResolutionListener arg2)
    {
        WorldMarshaller.PlaceResolutionMarshaller listener2 = new WorldMarshaller.PlaceResolutionMarshaller();
        listener2.listener = arg2;
        sendRequest(LOCATE_PLACE, new Object[] {
            arg1, listener2
        });
    }
}
