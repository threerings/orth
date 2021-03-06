//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import javax.annotation.Generated;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.party.client.PartyService;

/**
 * Provides the implementation of the {@link PartyService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PartyService.java.")
public class PartyMarshaller extends InvocationMarshaller<PartierObject>
    implements PartyService
{
    /** The method id used to dispatch {@link #assignLeader} requests. */
    public static final int ASSIGN_LEADER = 1;

    // from interface PartyService
    public void assignLeader (int arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(ASSIGN_LEADER, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #bootPlayer} requests. */
    public static final int BOOT_PLAYER = 2;

    // from interface PartyService
    public void bootPlayer (int arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(BOOT_PLAYER, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #invitePlayer} requests. */
    public static final int INVITE_PLAYER = 3;

    // from interface PartyService
    public void invitePlayer (PlayerName arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(INVITE_PLAYER, new Object[] {
            arg1, listener2
        });
    }

    /** The method id used to dispatch {@link #leaveParty} requests. */
    public static final int LEAVE_PARTY = 4;

    // from interface PartyService
    public void leaveParty (InvocationService.InvocationListener arg1)
    {
        ListenerMarshaller listener1 = new ListenerMarshaller();
        listener1.listener = arg1;
        sendRequest(LEAVE_PARTY, new Object[] {
            listener1
        });
    }

    /** The method id used to dispatch {@link #moveParty} requests. */
    public static final int MOVE_PARTY = 5;

    // from interface PartyService
    public void moveParty (HostedLocus arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(MOVE_PARTY, new Object[] {
            arg1, listener2
        });
    }

    /** The method id used to dispatch {@link #updateDisband} requests. */
    public static final int UPDATE_DISBAND = 6;

    // from interface PartyService
    public void updateDisband (boolean arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(UPDATE_DISBAND, new Object[] {
            Boolean.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #updatePolicy} requests. */
    public static final int UPDATE_POLICY = 7;

    // from interface PartyService
    public void updatePolicy (PartyPolicy arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(UPDATE_POLICY, new Object[] {
            arg1, listener2
        });
    }
}
