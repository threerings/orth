//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.locus.data;

import com.threerings.orth.data.ServerAddress;

public class HostedLocus extends ServerAddress
{
    public Locus locus;

    public HostedLocus(Locus locus, String host, int[] ports)
    {
        super(host, ports);
        this.locus = locus;
    }
}
