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
