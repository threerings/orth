//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.comms.data;

import com.threerings.presents.client.InvocationReceiver;

public interface CommReceiver
    extends InvocationReceiver
{
    void receiveComm (Object comm);
}
