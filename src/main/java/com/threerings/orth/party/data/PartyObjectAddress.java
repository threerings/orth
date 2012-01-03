//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import com.threerings.orth.data.ServerAddress;

public class PartyObjectAddress extends ServerAddress
{
    public int oid;

    public PartyObjectAddress (String hostName, int port, int oid)
    {
        super(hostName, new int[] {port});
        this.oid = oid;
    }
}
