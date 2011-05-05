//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.party.client {

import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.party.data.PartierObject;

/**
 * Provides access to distributed object services used by the party system.
 */
public interface PartyContext extends PresentsContext
{
    /**
     * Returns the context we use to obtain basic client services.
     */
    function getOrthContext () :OrthContext;

    /**
     * Returns our client object casted as a PartierObject.
     */
    function getPartierObject () :PartierObject;
}
}
