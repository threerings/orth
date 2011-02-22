//
// $Id$

package com.threerings.orth.aether.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.ClientManager;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.data.AuthName;

/**
 * Convenience class for finding {@link PlayerObject} instances logged into this server.
 */
@Singleton @EventThread
public class PlayerLocator
{
    public PlayerObject lookupPlayer (int playerId)
    {
        return forClient(_clientMgr.getClientObject(AuthName.makeKey(playerId)));
    }

    public PlayerObject forClient (ClientObject client)
    {
        return (PlayerObject) client;
    }

    @Inject protected ClientManager _clientMgr;
}
