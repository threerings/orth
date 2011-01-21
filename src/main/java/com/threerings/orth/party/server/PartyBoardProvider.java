//
// $Id$
package com.threerings.orth.party.server;

import javax.annotation.Generated;

import com.threerings.orth.party.client.PartyBoardService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link PartyBoardService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PartyBoardService.java.")
public interface PartyBoardProvider extends InvocationProvider
{
    /**
     * Handles a {@link PartyBoardService#createParty} request.
     */
    void createParty (ClientObject caller, String arg1, boolean arg2, PartyBoardService.JoinListener arg3)
        throws InvocationException;

    /**
     * Handles a {@link PartyBoardService#getPartyBoard} request.
     */
    void getPartyBoard (ClientObject caller, byte arg1, InvocationService.ResultListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyBoardService#getPartyDetail} request.
     */
    void getPartyDetail (ClientObject caller, int arg1, InvocationService.ResultListener arg2)
        throws InvocationException;

    /**
     * Handles a {@link PartyBoardService#locateParty} request.
     */
    void locateParty (ClientObject caller, int arg1, PartyBoardService.JoinListener arg2)
        throws InvocationException;
}
