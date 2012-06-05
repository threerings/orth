//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data {

import com.threerings.util.Integer;
import com.threerings.util.langBoolean;

import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.party.client.PartyService;

/**
 * Provides the implementation of the <code>PartyService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class PartyMarshaller extends InvocationMarshaller
    implements PartyService
{
    /** The method id used to dispatch <code>assignLeader</code> requests. */
    public static const ASSIGN_LEADER :int = 1;

    // from interface PartyService
    public function assignLeader (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(ASSIGN_LEADER, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>bootPlayer</code> requests. */
    public static const BOOT_PLAYER :int = 2;

    // from interface PartyService
    public function bootPlayer (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(BOOT_PLAYER, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>invitePlayer</code> requests. */
    public static const INVITE_PLAYER :int = 3;

    // from interface PartyService
    public function invitePlayer (arg1 :PlayerName, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(INVITE_PLAYER, [
            arg1, listener2
        ]);
    }

    /** The method id used to dispatch <code>leaveParty</code> requests. */
    public static const LEAVE_PARTY :int = 4;

    // from interface PartyService
    public function leaveParty (arg1 :InvocationService_InvocationListener) :void
    {
        var listener1 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener1.listener = arg1;
        sendRequest(LEAVE_PARTY, [
            listener1
        ]);
    }

    /** The method id used to dispatch <code>moveParty</code> requests. */
    public static const MOVE_PARTY :int = 5;

    // from interface PartyService
    public function moveParty (arg1 :HostedLocus, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(MOVE_PARTY, [
            arg1, listener2
        ]);
    }

    /** The method id used to dispatch <code>updateDisband</code> requests. */
    public static const UPDATE_DISBAND :int = 6;

    // from interface PartyService
    public function updateDisband (arg1 :Boolean, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(UPDATE_DISBAND, [
            langBoolean.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>updatePolicy</code> requests. */
    public static const UPDATE_POLICY :int = 7;

    // from interface PartyService
    public function updatePolicy (arg1 :PartyPolicy, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(UPDATE_POLICY, [
            arg1, listener2
        ]);
    }
}
}
