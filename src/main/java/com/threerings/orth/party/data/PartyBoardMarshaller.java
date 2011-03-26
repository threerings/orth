//
// $Id$
package com.threerings.orth.party.data;

import javax.annotation.Generated;

import com.threerings.orth.party.client.PartyBoardService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.dobj.InvocationResponseEvent;

/**
 * Provides the implementation of the {@link PartyBoardService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PartyBoardService.java.")
public class PartyBoardMarshaller extends InvocationMarshaller
    implements PartyBoardService
{
    /**
     * Marshalls results to implementations of {@code PartyBoardService.JoinListener}.
     */
    public static class JoinMarshaller extends ListenerMarshaller
        implements JoinListener
    {
        /** The method id used to dispatch {@link #foundParty}
         * responses. */
        public static final int FOUND_PARTY = 1;

        // from interface JoinMarshaller
        public void foundParty (int arg1, String arg2, int arg3)
        {
            _invId = null;
            omgr.postEvent(new InvocationResponseEvent(
                               callerOid, requestId, FOUND_PARTY,
                               new Object[] { Integer.valueOf(arg1), arg2, Integer.valueOf(arg3) }, transport));
        }

        @Override // from InvocationMarshaller
        public void dispatchResponse (int methodId, Object[] args)
        {
            switch (methodId) {
            case FOUND_PARTY:
                ((JoinListener)listener).foundParty(
                    ((Integer)args[0]).intValue(), (String)args[1], ((Integer)args[2]).intValue());
                return;

            default:
                super.dispatchResponse(methodId, args);
                return;
            }
        }
    }

    /** The method id used to dispatch {@link #createParty} requests. */
    public static final int CREATE_PARTY = 1;

    // from interface PartyBoardService
    public void createParty (String arg1, boolean arg2, PartyBoardService.JoinListener arg3)
    {
        PartyBoardMarshaller.JoinMarshaller listener3 = new PartyBoardMarshaller.JoinMarshaller();
        listener3.listener = arg3;
        sendRequest(CREATE_PARTY, new Object[] {
            arg1, Boolean.valueOf(arg2), listener3
        });
    }

    /** The method id used to dispatch {@link #getPartyBoard} requests. */
    public static final int GET_PARTY_BOARD = 2;

    // from interface PartyBoardService
    public void getPartyBoard (byte arg1, InvocationService.ResultListener arg2)
    {
        InvocationMarshaller.ResultMarshaller listener2 = new InvocationMarshaller.ResultMarshaller();
        listener2.listener = arg2;
        sendRequest(GET_PARTY_BOARD, new Object[] {
            Byte.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #getPartyDetail} requests. */
    public static final int GET_PARTY_DETAIL = 3;

    // from interface PartyBoardService
    public void getPartyDetail (int arg1, InvocationService.ResultListener arg2)
    {
        InvocationMarshaller.ResultMarshaller listener2 = new InvocationMarshaller.ResultMarshaller();
        listener2.listener = arg2;
        sendRequest(GET_PARTY_DETAIL, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #locateParty} requests. */
    public static final int LOCATE_PARTY = 4;

    // from interface PartyBoardService
    public void locateParty (int arg1, PartyBoardService.JoinListener arg2)
    {
        PartyBoardMarshaller.JoinMarshaller listener2 = new PartyBoardMarshaller.JoinMarshaller();
        listener2.listener = arg2;
        sendRequest(LOCATE_PARTY, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }
}
