//
// $Id$
package com.threerings.orth.world.client {

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java WorldService interface.
 */
public interface WorldService extends InvocationService
{
    // from Java interface WorldService
    function ditchFollower (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface WorldService
    function followMember (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface WorldService
    function inviteToFollow (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface WorldService
    function setAvatar (arg1 :int, arg2 :InvocationService_ConfirmListener) :void;
}
}
