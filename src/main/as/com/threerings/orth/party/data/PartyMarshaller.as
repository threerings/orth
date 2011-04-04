//
// $Id$

package com.threerings.orth.party.data {

import com.threerings.util.Byte;
import com.threerings.util.Integer;
import com.threerings.util.langBoolean;

import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

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
    public function invitePlayer (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(INVITE_PLAYER, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>moveParty</code> requests. */
    public static const MOVE_PARTY :int = 4;

    // from interface PartyService
    public function moveParty (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(MOVE_PARTY, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>updateDisband</code> requests. */
    public static const UPDATE_DISBAND :int = 5;

    // from interface PartyService
    public function updateDisband (arg1 :Boolean, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(UPDATE_DISBAND, [
            langBoolean.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>updateRecruitment</code> requests. */
    public static const UPDATE_RECRUITMENT :int = 6;

    // from interface PartyService
    public function updateRecruitment (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(UPDATE_RECRUITMENT, [
            Byte.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>updateStatus</code> requests. */
    public static const UPDATE_STATUS :int = 7;

    // from interface PartyService
    public function updateStatus (arg1 :String, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(UPDATE_STATUS, [
            arg1, listener2
        ]);
    }
}
}
