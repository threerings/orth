//
// $Id$

package com.threerings.orth.aether.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java FriendService interface.
 */
public interface FriendService extends InvocationService
{
    // from Java interface FriendService
    function acceptFriendshipRequest (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface FriendService
    function requestFriendship (arg1 :int, arg2 :InvocationService_InvocationListener) :void;
}
}
