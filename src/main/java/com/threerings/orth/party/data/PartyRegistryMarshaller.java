//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import javax.annotation.Generated;

import com.threerings.orth.party.client.PartyRegistryService;
import com.threerings.presents.client.InvocationService;
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
    /** The method id used to dispatch {@link #createParty} requests. */
    public static final int CREATE_PARTY = 1;

    // from interface PartyRegistryService
    public void createParty (String arg1, boolean arg2, InvocationService.ResultListener arg3)
    {
        InvocationMarshaller.ResultMarshaller listener3 = new InvocationMarshaller.ResultMarshaller();
        listener3.listener = arg3;
        sendRequest(CREATE_PARTY, new Object[] {
            arg1, Boolean.valueOf(arg2), listener3
        });
    }
}
