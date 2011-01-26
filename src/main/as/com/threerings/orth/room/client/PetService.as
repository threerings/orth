//
// $Id$
package com.threerings.orth.room.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ConfirmListener;

/**
 * An ActionScript version of the Java PetService interface.
 */
public interface PetService extends InvocationService
{
    // from Java interface PetService
    function callPet (arg1 :int, arg2 :InvocationService_ConfirmListener) :void;

    // from Java interface PetService
    function orderPet (arg1 :int, arg2 :int, arg3 :InvocationService_ConfirmListener) :void;

    // from Java interface PetService
    function sendChat (arg1 :int, arg2 :int, arg3 :String, arg4 :InvocationService_ConfirmListener) :void;
}
}
