//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.nodelet.data;

import com.threerings.presents.dobj.DSet;

import com.threerings.orth.data.ServerAddress;

public final class HostedNodelet extends ServerAddress
    implements DSet.Entry
{
    public Nodelet nodelet;

    public HostedNodelet (Nodelet nodelet, String host, int[] ports)
    {
        super(host, ports);
        this.nodelet = nodelet;
    }

    @Override
    public Comparable<?> getKey ()
    {
        return nodelet.getKey();
    }
}
