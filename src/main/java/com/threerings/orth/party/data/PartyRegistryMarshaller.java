//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.party.client.PartyRegistryService;

/**
 * Provides the implementation of the {@link PartyRegistryService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PartyRegistryService.java.")
public class PartyRegistryMarshaller extends InvocationMarshaller<AetherClientObject>
    implements PartyRegistryService
{
    /** The method id used to dispatch {@link #createParty} requests. */
    public static final int CREATE_PARTY = 1;

    // from interface PartyRegistryService
    public void createParty (PartyConfig arg1, InvocationService.ResultListener arg2)
    {
        InvocationMarshaller.ResultMarshaller listener2 = new InvocationMarshaller.ResultMarshaller();
        listener2.listener = arg2;
        sendRequest(CREATE_PARTY, new Object[] {
            arg1, listener2
        });
    }
}
