//
// $Id$

package com.threerings.orth.aether.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java PlayerService interface.
 */
public interface PlayerService extends InvocationService
{
    // from Java interface PlayerService
    function acceptFriendshipRequest (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface PlayerService
    function createGuild (arg1 :String, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface PlayerService
    function dispatchDeferredNotifications () :void;

    // from Java interface PlayerService
    function ditchFollower (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface PlayerService
    function followPlayer (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface PlayerService
    function inviteToFollow (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface PlayerService
    function requestFriendship (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface PlayerService
    function setAvatar (arg1 :int, arg2 :InvocationService_ConfirmListener) :void;
}
}
