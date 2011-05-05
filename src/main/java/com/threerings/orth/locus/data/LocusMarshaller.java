//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.locus.data;

import javax.annotation.Generated;

import com.threerings.orth.locus.client.LocusService;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.presents.data.InvocationMarshaller;

/**
 * Provides the implementation of the {@link LocusService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from LocusService.java.")
public class LocusMarshaller extends InvocationMarshaller
    implements LocusService
{
    /**
     * Marshalls results to implementations of {@code LocusService.LocusMaterializationListener}.
     */
    public static class LocusMaterializationMarshaller extends ListenerMarshaller
        implements LocusMaterializationListener
    {
        /** The method id used to dispatch {@link #locusMaterialized}
         * responses. */
        public static final int LOCUS_MATERIALIZED = 1;

        // from interface LocusMaterializationMarshaller
        public void locusMaterialized (HostedNodelet arg1)
        {
            sendResponse(LOCUS_MATERIALIZED, new Object[] { arg1 });
        }

        @Override // from InvocationMarshaller
        public void dispatchResponse (int methodId, Object[] args)
        {
            switch (methodId) {
            case LOCUS_MATERIALIZED:
                ((LocusMaterializationListener)listener).locusMaterialized(
                    (HostedNodelet)args[0]);
                return;

            default:
                super.dispatchResponse(methodId, args);
                return;
            }
        }
    }

    /** The method id used to dispatch {@link #materializeLocus} requests. */
    public static final int MATERIALIZE_LOCUS = 1;

    // from interface LocusService
    public void materializeLocus (Locus arg1, LocusService.LocusMaterializationListener arg2)
    {
        LocusMarshaller.LocusMaterializationMarshaller listener2 = new LocusMarshaller.LocusMaterializationMarshaller();
        listener2.listener = arg2;
        sendRequest(MATERIALIZE_LOCUS, new Object[] {
            arg1, listener2
        });
    }
}
