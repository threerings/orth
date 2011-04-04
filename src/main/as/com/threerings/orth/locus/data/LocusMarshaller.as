//
// $Id$

package com.threerings.orth.locus.data {

import com.threerings.presents.data.InvocationMarshaller;

import com.threerings.orth.locus.client.LocusService;
import com.threerings.orth.locus.client.LocusService_LocusMaterializationListener;

/**
 * Provides the implementation of the <code>LocusService</code> interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
public class LocusMarshaller extends InvocationMarshaller
    implements LocusService
{
    /** The method id used to dispatch <code>materializeLocus</code> requests. */
    public static const MATERIALIZE_LOCUS :int = 1;

    // from interface LocusService
    public function materializeLocus (arg1 :Locus, arg2 :LocusService_LocusMaterializationListener) :void
    {
        var listener2 :LocusMarshaller_LocusMaterializationMarshaller = new LocusMarshaller_LocusMaterializationMarshaller();
        listener2.listener = arg2;
        sendRequest(MATERIALIZE_LOCUS, [
            arg1, listener2
        ]);
    }
}
}
