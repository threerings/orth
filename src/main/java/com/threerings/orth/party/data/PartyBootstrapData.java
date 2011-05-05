//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import com.threerings.presents.net.BootstrapData;

/**
 * Bootstrap data provided to a party client connection.
 */
public class PartyBootstrapData extends BootstrapData
{
    /** The oid of the client's party object. */
    public int partyOid;
}
