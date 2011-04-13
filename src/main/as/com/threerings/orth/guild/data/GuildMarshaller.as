//
// $Id$

package com.threerings.orth.guild.data {

import com.threerings.util.Integer;

import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.data.InvocationMarshaller_ListenerMarshaller;

import com.threerings.orth.guild.client.GuildService;

/**
 * Provides the implementation of the <code>GuildService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class GuildMarshaller extends InvocationMarshaller
    implements GuildService
{
    /** The method id used to dispatch <code>sendInvite</code> requests. */
    public static const SEND_INVITE :int = 1;

    // from interface GuildService
    public function sendInvite (arg1 :int, arg2 :InvocationService_InvocationListener) :void
    {
        var listener2 :InvocationMarshaller_ListenerMarshaller = new InvocationMarshaller_ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(SEND_INVITE, [
            Integer.valueOf(arg1), listener2
        ]);
    }
}
}
