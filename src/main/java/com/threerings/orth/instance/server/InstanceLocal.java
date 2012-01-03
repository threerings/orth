//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.instance.server;

import com.threerings.presents.server.ClientLocal;

import com.threerings.orth.instance.data.Instance;

public class InstanceLocal extends ClientLocal
{
    public Instance instance;
    public long entered;
}
