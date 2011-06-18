//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.party.client.PartyRegistryDecoder;
import com.threerings.orth.party.client.PartyRegistryReceiver;
import com.threerings.orth.party.data.PartyObjectAddress;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationSender;

/**
 * Used to issue notifications to a {@link PartyRegistryReceiver} instance on a
 * client.
 */
public class PartyRegistrySender extends InvocationSender
{
    /**
     * Issues a notification that will result in a call to {@link
     * PartyRegistryReceiver#receiveInvitation} on a client.
     */
    public static void receiveInvitation (
        ClientObject target, PlayerName arg1, PartyObjectAddress arg2)
    {
        sendNotification(
            target, PartyRegistryDecoder.RECEIVER_CODE, PartyRegistryDecoder.RECEIVE_INVITATION,
            new Object[] { arg1, arg2 });
    }

}
