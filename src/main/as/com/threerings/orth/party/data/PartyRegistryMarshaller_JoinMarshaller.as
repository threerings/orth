//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.data {

import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.party.client.PartyRegistryService_JoinListener;

/**
 * Marshalls instances of the PartyRegistryService_JoinMarshaller interface.
 */
public class PartyRegistryMarshaller_JoinMarshaller
    extends InvocationMarshaller_ListenerMarshaller
{
    /** The method id used to dispatch <code>foundParty</code> responses. */
    public static const FOUND_PARTY :int = 1;

    // from InvocationMarshaller_ListenerMarshaller
    override public function dispatchResponse (methodId :int, args :Array) :void
    {
        switch (methodId) {
        case FOUND_PARTY:
            (listener as PartyRegistryService_JoinListener).foundParty(
                (args[0] as int), (args[1] as String), (args[2] as int));
            return;

        default:
            super.dispatchResponse(methodId, args);
            return;
        }
    }
}
}
