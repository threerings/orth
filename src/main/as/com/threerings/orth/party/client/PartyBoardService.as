//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.party.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_ResultListener;

/**
 * An ActionScript version of the Java PartyBoardService interface.
 */
public interface PartyBoardService extends InvocationService
{
    // from Java interface PartyBoardService
    function createParty (arg1 :String, arg2 :Boolean, arg3 :PartyBoardService_JoinListener) :void;

    // from Java interface PartyBoardService
    function getPartyBoard (arg1 :int, arg2 :InvocationService_ResultListener) :void;

    // from Java interface PartyBoardService
    function getPartyDetail (arg1 :int, arg2 :InvocationService_ResultListener) :void;

    // from Java interface PartyBoardService
    function locateParty (arg1 :int, arg2 :PartyBoardService_JoinListener) :void;
}
}
