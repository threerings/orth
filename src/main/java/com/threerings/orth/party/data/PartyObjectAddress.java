package com.threerings.orth.party.data;

import com.threerings.io.SimpleStreamableObject;

public class PartyObjectAddress extends SimpleStreamableObject
{
    public final String hostName;

    public final int port, oid;

    public PartyObjectAddress (String hostName, int port, int oid)
    {
        this.hostName = hostName;
        this.port = port;
        this.oid = oid;
    }
}
