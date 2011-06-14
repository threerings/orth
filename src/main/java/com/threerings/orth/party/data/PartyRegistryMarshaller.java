//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import javax.annotation.Generated;

import com.threerings.orth.party.client.PartyRegistryService;
import com.threerings.presents.data.InvocationMarshaller;

/**
 * Provides the implementation of the {@link PartyRegistryService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PartyRegistryService.java.")
public class PartyRegistryMarshaller extends InvocationMarshaller
    implements PartyRegistryService
{
    /**
     * Marshalls results to implementations of {@code PartyRegistryService.JoinListener}.
     */
    public static class JoinMarshaller extends ListenerMarshaller
        implements JoinListener
    {
        /** The method id used to dispatch {@link #foundParty}
         * responses. */
        public static final int FOUND_PARTY = 1;

        // from interface JoinMarshaller
        public void foundParty (int arg1, String arg2, int arg3)
        {
            sendResponse(FOUND_PARTY, new Object[] { Integer.valueOf(arg1), arg2, Integer.valueOf(arg3) });
        }

        @Override // from InvocationMarshaller
        public void dispatchResponse (int methodId, Object[] args)
        {
            switch (methodId) {
            case FOUND_PARTY:
                ((JoinListener)listener).foundParty(
                    ((Integer)args[0]).intValue(), (String)args[1], ((Integer)args[2]).intValue());
                return;

            default:
                super.dispatchResponse(methodId, args);
                return;
            }
        }
    }

    /** The method id used to dispatch {@link #createParty} requests. */
    public static final int CREATE_PARTY = 1;

    // from interface PartyRegistryService
    public void createParty (String arg1, boolean arg2, PartyRegistryService.JoinListener arg3)
    {
        PartyRegistryMarshaller.JoinMarshaller listener3 = new PartyRegistryMarshaller.JoinMarshaller();
        listener3.listener = arg3;
        sendRequest(CREATE_PARTY, new Object[] {
            arg1, Boolean.valueOf(arg2), listener3
        });
    }

    /** The method id used to dispatch {@link #locateParty} requests. */
    public static final int LOCATE_PARTY = 2;

    // from interface PartyRegistryService
    public void locateParty (int arg1, PartyRegistryService.JoinListener arg2)
    {
        PartyRegistryMarshaller.JoinMarshaller listener2 = new PartyRegistryMarshaller.JoinMarshaller();
        listener2.listener = arg2;
        sendRequest(LOCATE_PARTY, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }
}
