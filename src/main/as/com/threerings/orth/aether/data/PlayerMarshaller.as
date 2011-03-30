//
// $Id$
package com.threerings.orth.aether.data {

import com.threerings.util.Integer;

import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ConfirmMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.aether.client.PlayerService;

/**
 * Provides the implementation of the <code>PlayerService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class PlayerMarshaller extends InvocationMarshaller
    implements PlayerService
{
    /** The method id used to dispatch <code>acceptFriendshipRequest</code> requests. */
    public static const ACCEPT_FRIENDSHIP_REQUEST :int = 1;

    // from interface PlayerService
    public function acceptFriendshipRequest (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(ACCEPT_FRIENDSHIP_REQUEST, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>ditchFollower</code> requests. */
    public static const DITCH_FOLLOWER :int = 2;

    // from interface PlayerService
    public function ditchFollower (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(DITCH_FOLLOWER, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>followPlayer</code> requests. */
    public static const FOLLOW_PLAYER :int = 3;

    // from interface PlayerService
    public function followPlayer (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(FOLLOW_PLAYER, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>inviteToFollow</code> requests. */
    public static const INVITE_TO_FOLLOW :int = 4;

    // from interface PlayerService
    public function inviteToFollow (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(INVITE_TO_FOLLOW, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>requestFriendship</code> requests. */
    public static const REQUEST_FRIENDSHIP :int = 5;

    // from interface PlayerService
    public function requestFriendship (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(REQUEST_FRIENDSHIP, [
            Integer.valueOf(arg1), listener2
        ]);
    }

    /** The method id used to dispatch <code>setAvatar</code> requests. */
    public static const SET_AVATAR :int = 6;

    // from interface PlayerService
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
