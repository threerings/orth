//
// $Id$
package com.threerings.orth.world.data {

import com.threerings.orth.world.client.WorldService;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ConfirmMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;
import com.threerings.util.Integer;

/**
 * Provides the implementation of the <code>WorldService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class WorldMarshaller extends InvocationMarshaller
    implements WorldService
{
    /** The method id used to dispatch <code>ditchFollower</code> requests. */
    public static const DITCH_FOLLOWER :int = 1;

    // from interface WorldService
    public function ditchFollower (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(DITCH_FOLLOWER, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>followMember</code> requests. */
    public static const FOLLOW_MEMBER :int = 2;

    // from interface WorldService
    public function followMember (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(FOLLOW_MEMBER, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>inviteToFollow</code> requests. */
    public static const INVITE_TO_FOLLOW :int = 3;

    // from interface WorldService
    public function inviteToFollow (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(INVITE_TO_FOLLOW, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>setAvatar</code> requests. */
    public static const SET_AVATAR :int = 4;

    // from interface WorldService
    public function setAvatar (arg1 :int, arg2 :InvocationService_ConfirmListener) :void
    {
        var listener2 :InvocationMarshaller_ConfirmMarshaller = new InvocationMarshaller_ConfirmMarshaller();
        listener2.listener = arg2;
        sendRequest(SET_AVATAR, [
            Integer.valueOf(arg1), listener2
        ]);
    }
}
}
