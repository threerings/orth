//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.comms.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.server.ClientManager;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.comms.data.CommSender;
import com.threerings.orth.comms.data.OneToOneComm;

/**
 * A class for handling non-trivial {@link OneToOneComm} requests.
 */
@Singleton @EventThread
public class CommsManager
{
    /**
     * Send a comm to every player on the server by iterating over all our
     * resolved aether connections.
     *
     * TODO: Use instead a {@link DObject} that *every* client is always subscribed to?
     */
    public void broadcast (Object comm)
    {
        for (ClientObject clobj : _clmgr.clientObjects()) {
            if (clobj.username instanceof AetherAuthName) {
                CommSender.receiveComm(clobj, comm);
            }
        }
    }

    @Inject protected ClientManager _clmgr;
}
