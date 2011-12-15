//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.comms.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.data.ClientObject;
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
     * Send a {@link OneToOneComm} to every player on the server by iterating over all our
     * resolved aether connections.
     *
     * TODO: Use instead a {@link DObject} that *every* client is always subscribed to?
     */
    public void broadcast (OneToOneComm comm)
    {
        for (ClientObject clobj : _clmgr.clientObjects()) {
            if (clobj.username instanceof AetherAuthName) {
                CommSender.receiveComm(clobj, comm);
            }
        }
    }

    @Inject protected ClientManager _clmgr;
}
