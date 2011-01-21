//
// $Id$
package com.threerings.orth.room.data;

import javax.annotation.Generated;

import com.threerings.orth.room.client.PetService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;

/**
 * Provides the implementation of the {@link PetService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PetService.java.")
public class PetMarshaller extends InvocationMarshaller
    implements PetService
{
    /** The method id used to dispatch {@link #callPet} requests. */
    public static final int CALL_PET = 1;

    // from interface PetService
    public void callPet (int arg1, InvocationService.ConfirmListener arg2)
    {
        InvocationMarshaller.ConfirmMarshaller listener2 = new InvocationMarshaller.ConfirmMarshaller();
        listener2.listener = arg2;
        sendRequest(CALL_PET, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #orderPet} requests. */
    public static final int ORDER_PET = 2;

    // from interface PetService
    public void orderPet (int arg1, int arg2, InvocationService.ConfirmListener arg3)
    {
        InvocationMarshaller.ConfirmMarshaller listener3 = new InvocationMarshaller.ConfirmMarshaller();
        listener3.listener = arg3;
        sendRequest(ORDER_PET, new Object[] {
            Integer.valueOf(arg1), Integer.valueOf(arg2), listener3
        });
    }

    /** The method id used to dispatch {@link #sendChat} requests. */
    public static final int SEND_CHAT = 3;

    // from interface PetService
    public void sendChat (int arg1, int arg2, String arg3, InvocationService.ConfirmListener arg4)
    {
        InvocationMarshaller.ConfirmMarshaller listener4 = new InvocationMarshaller.ConfirmMarshaller();
        listener4.listener = arg4;
        sendRequest(SEND_CHAT, new Object[] {
            Integer.valueOf(arg1), Integer.valueOf(arg2), arg3, listener4
        });
    }
}
