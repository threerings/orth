//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.threerings.io.SimpleStreamableObject;

public class ServerAddress extends SimpleStreamableObject
{
    public String host;
    public int[] ports;

    public ServerAddress (String host, int[] ports)
    {
        this.host = host;
        this.ports = ports;
    }
}
