//
// $Id: PartyContext.as 16175 2009-04-23 20:56:15Z ray $

package com.threerings.orth.party.client {

import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.world.client.WorldContext;

import com.threerings.orth.party.data.PartierObject;

/**
 * Provides access to distributed object services used by the party system.
 */
public interface PartyContext extends PresentsContext
{
    /**
     * Returns the context we use to obtain basic client services.
     */
    function getWorldContext () :WorldContext;

    /**
     * Returns our client object casted as a PartierObject.
     */
    function getPartierObject () :PartierObject;
}
}
