//
// $Id$

package com.threerings.orth.party.server;

import javax.annotation.Generated;

import com.threerings.orth.party.client.PartyBoardService;
import com.threerings.orth.party.data.PartyBoardMarshaller;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;

/**
 * Dispatches requests to the {@link PartyBoardProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PartyBoardService.java.")
public class PartyBoardDispatcher extends InvocationDispatcher<PartyBoardMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public PartyBoardDispatcher (PartyBoardProvider provider)
    {
        this.provider = provider;
    }

    @Override
    public PartyBoardMarshaller createMarshaller ()
    {
        return new PartyBoardMarshaller();
    }

    @Override
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case PartyBoardMarshaller.CREATE_PARTY:
            ((PartyBoardProvider)provider).createParty(
                source, (String)args[0], ((Boolean)args[1]).booleanValue(), (PartyBoardService.JoinListener)args[2]
            );
            return;

        case PartyBoardMarshaller.GET_PARTY_BOARD:
            ((PartyBoardProvider)provider).getPartyBoard(
                source, ((Byte)args[0]).byteValue(), (InvocationService.ResultListener)args[1]
            );
            return;

        case PartyBoardMarshaller.GET_PARTY_DETAIL:
            ((PartyBoardProvider)provider).getPartyDetail(
                source, ((Integer)args[0]).intValue(), (InvocationService.ResultListener)args[1]
            );
            return;

        case PartyBoardMarshaller.LOCATE_PARTY:
            ((PartyBoardProvider)provider).locateParty(
                source, ((Integer)args[0]).intValue(), (PartyBoardService.JoinListener)args[1]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
