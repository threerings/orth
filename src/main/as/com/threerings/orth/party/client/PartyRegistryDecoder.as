//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client {

import com.threerings.presents.client.InvocationDecoder;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.party.data.PartyObjectAddress;

/**
 * Dispatches calls to a {@link PartyRegistryReceiver} instance.
 */
public class PartyRegistryDecoder extends InvocationDecoder
{
    /** The generated hash code used to identify this receiver class. */
    public static const RECEIVER_CODE :String = "05c7a764db18158562a2bd55d300956b";

    /** The method id used to dispatch {@link PartyRegistryReceiver#receiveInvitation}
     * notifications. */
    public static const RECEIVE_INVITATION :int = 1;

    /**
     * Creates a decoder that may be registered to dispatch invocation
     * service notifications to the specified receiver.
     */
    public function PartyRegistryDecoder (receiver :PartyRegistryReceiver)
    {
        this.receiver = receiver;
    }

    public override function getReceiverCode () :String
    {
        return RECEIVER_CODE;
    }

    public override function dispatchNotification (methodId :int, args :Array) :void
    {
        switch (methodId) {
        case RECEIVE_INVITATION:
            PartyRegistryReceiver(receiver).receiveInvitation(
                (args[0] as PlayerName), (args[1] as PartyObjectAddress)
            );
            return;

        default:
            super.dispatchNotification(methodId, args);
        }
    }
}
}
