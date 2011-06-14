//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.data {

import com.threerings.util.Integer;
import com.threerings.util.langBoolean;

import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.orth.party.client.PartyRegistryService;
import com.threerings.orth.party.client.PartyRegistryService_JoinListener;

/**
 * Provides the implementation of the <code>PartyRegistryService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class PartyRegistryMarshaller extends InvocationMarshaller
    implements PartyRegistryService
{
    /** The method id used to dispatch <code>createParty</code> requests. */
    public static const CREATE_PARTY :int = 1;

    // from interface PartyRegistryService
    public function createParty (arg1 :String, arg2 :Boolean, arg3 :PartyRegistryService_JoinListener) :void
    {
        var listener3 :PartyRegistryMarshaller_JoinMarshaller = new PartyRegistryMarshaller_JoinMarshaller();
        listener3.listener = arg3;
        sendRequest(CREATE_PARTY, [
            arg1, langBoolean.valueOf(arg2), listener3
        ]);
    }

    /** The method id used to dispatch <code>locateParty</code> requests. */
    public static const LOCATE_PARTY :int = 2;

    // from interface PartyRegistryService
    public function locateParty (arg1 :int, arg2 :PartyRegistryService_JoinListener) :void
    {
        var listener2 :PartyRegistryMarshaller_JoinMarshaller = new PartyRegistryMarshaller_JoinMarshaller();
        listener2.listener = arg2;
        sendRequest(LOCATE_PARTY, [
            Integer.valueOf(arg1), listener2
        ]);
    }
}
}
