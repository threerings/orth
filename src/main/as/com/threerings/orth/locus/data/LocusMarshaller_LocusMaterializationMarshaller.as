//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.locus.data {

import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.locus.client.LocusService_LocusMaterializationListener;

/**
 * Marshalls instances of the LocusService_LocusMaterializationMarshaller interface.
 */
public class LocusMarshaller_LocusMaterializationMarshaller
    extends InvocationMarshaller_ListenerMarshaller
{
    /** The method id used to dispatch <code>locusMaterialized</code> responses. */
    public static const LOCUS_MATERIALIZED :int = 1;

    // from InvocationMarshaller_ListenerMarshaller
    override public function dispatchResponse (methodId :int, args :Array) :void
    {
        switch (methodId) {
        case LOCUS_MATERIALIZED:
            (listener as LocusService_LocusMaterializationListener).locusMaterialized(
                (args[0] as HostedLocus));
            return;

        default:
            super.dispatchResponse(methodId, args);
            return;
        }
    }
}
}
