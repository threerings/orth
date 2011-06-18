//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.party.data.PartyObjectAddress;
import com.threerings.presents.client.InvocationDecoder;

/**
 * Dispatches calls to a {@link PartyRegistryReceiver} instance.
 */
public class PartyRegistryDecoder extends InvocationDecoder
{
    /** The generated hash code used to identify this receiver class. */
    public static final String RECEIVER_CODE = "05c7a764db18158562a2bd55d300956b";

    /** The method id used to dispatch {@link PartyRegistryReceiver#receiveInvitation}
     * notifications. */
    public static final int RECEIVE_INVITATION = 1;

    /**
     * Creates a decoder that may be registered to dispatch invocation
     * service notifications to the specified receiver.
     */
    public PartyRegistryDecoder (PartyRegistryReceiver receiver)
    {
        this.receiver = receiver;
    }

    @Override
    public String getReceiverCode ()
    {
        return RECEIVER_CODE;
    }

    @Override
    public void dispatchNotification (int methodId, Object[] args)
    {
        switch (methodId) {
        case RECEIVE_INVITATION:
            ((PartyRegistryReceiver)receiver).receiveInvitation(
                (PlayerName)args[0], (PartyObjectAddress)args[1]
            );
            return;

        default:
            super.dispatchNotification(methodId, args);
            return;
        }
    }
}
