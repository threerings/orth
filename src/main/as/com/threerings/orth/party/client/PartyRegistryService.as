//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client {

import com.threerings.presents.client.InvocationService;

/**
 * An ActionScript version of the Java PartyRegistryService interface.
 */
public interface PartyRegistryService extends InvocationService
{
    // from Java interface PartyRegistryService
    function createParty (arg1 :String, arg2 :Boolean, arg3 :PartyRegistryService_JoinListener) :void;

    // from Java interface PartyRegistryService
    function locateParty (arg1 :int, arg2 :PartyRegistryService_JoinListener) :void;
}
}
