//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ResultListener;

/**
 * An ActionScript version of the Java PartyRegistryService interface.
 */
public interface PartyRegistryService extends InvocationService
{
    // from Java interface PartyRegistryService
    function createParty (arg1 :InvocationService_ResultListener) :void;
}
}
